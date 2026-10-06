"""dirbusy - find out which processes are keeping a directory (or mount)
busy, and interactively kill them or unmount once it's clear.

Built for the case of an sshfs/FUSE mount that refuses to unmount: point it
at the mountpoint, see who's holding it open (down to the individual file,
recursively, to a configurable depth), kill the offenders, and unmount.

USAGE
  dirbusy list DIR [--depth N]
      Show every process using DIR or anything under it, and which files
      it's holding open.

  dirbusy kill DIR [--depth N] [--all] [--pid PID ...] [--signal SIG] [-y]
      Same discovery as `list`, then kill processes: pick numbers
      interactively, or pass --all / --pid to skip the prompt.

  dirbusy unmount DIR [--depth N] [--lazy] [-y]
      Full workflow: scan, offer to kill the processes found (one at a
      time, all at once, or rescan), and once nothing is left, unmount
      DIR (fusermount -u for FUSE mounts, umount otherwise).

DEPTH
  DIR itself is always checked. If DIR is a mountpoint, the whole
  filesystem is also checked via `fuser -m` (catches anything anywhere on
  it, regardless of depth). --depth (default 3) additionally controls how
  many directory levels under DIR get walked file-by-file to report
  exactly which files are open; raise it if a holder is deeper than that
  and doesn't show up under `fuser -m`.
"""

import argparse
import os
import pwd
import re
import signal
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

DEFAULT_DEPTH = 3
MAX_WORKERS = 16

# NixOS's default `fuser` on PATH is BusyBox's (no -m support, no multi-file
# support) - a real psmisc build is substituted in at build time.
FUSER_BIN = "@FUSER@"

# fuser writes pids to stdout and, with -v, human-readable rows (including
# the per-pid access-type letters) to stderr - with no way to line the two
# streams up reliably when querying several paths in one call. Querying one
# path at a time keeps them in lockstep (same process order on both
# streams), so each path is queried individually and the streams are zipped.
PID_TOKEN_RE = re.compile(r"^(\d+)$")
ACCESS_ROW_RE = re.compile(r"^(?:\S.*?:)?\s*\S+\s+([\w.]{5})\s+\S")

ACCESS_MEANINGS = {
    "c": "cwd",
    "e": "executable",
    "f": "open file",
    "F": "open file (write)",
    "r": "root dir",
    "m": "mmap/shared lib",
}


def describe_access(code):
    meanings = [ACCESS_MEANINGS[c] for c in code if c in ACCESS_MEANINGS]
    return "/".join(meanings) if meanings else "open"


def eprint(*a, **kw):
    print(*a, file=sys.stderr, **kw)


def die(msg, code=1):
    eprint(f"dirbusy: {msg}")
    sys.exit(code)


def resolve_dir(path):
    path = os.path.abspath(os.path.expanduser(path))
    if not os.path.isdir(path):
        die(f"not a directory: {path}")
    return path


def collect_paths(root, max_depth):
    """root itself, plus its contents walked up to max_depth levels deep."""
    paths = [root]
    root_depth = root.rstrip(os.sep).count(os.sep)
    for dirpath, dirnames, filenames in os.walk(root):
        depth = dirpath.rstrip(os.sep).count(os.sep) - root_depth
        if depth >= max_depth:
            dirnames[:] = []
            continue
        for name in dirnames + filenames:
            paths.append(os.path.join(dirpath, name))
    return paths


def _fuser_pids(args):
    proc = subprocess.run(
        [FUSER_BIN] + args,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    pids = set()
    for token in proc.stdout.split():
        m = PID_TOKEN_RE.match(token)
        if m:
            pids.add(int(m.group(1)))
    return pids


def _fuser_verbose_one(path):
    """[(pid, access_code), ...] for a single path, in fuser's own order."""
    proc = subprocess.run(
        [FUSER_BIN, "-v", path],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    pids = [
        int(m.group(1))
        for tok in proc.stdout.split()
        if (m := PID_TOKEN_RE.match(tok))
    ]
    rows = [
        m.group(1)
        for line in proc.stderr.splitlines()
        if "COMMAND" not in line and (m := ACCESS_ROW_RE.match(line))
    ]
    if len(rows) != len(pids):
        # Streams didn't line up as expected - fall back to no access info
        # rather than risk mis-attributing one pid's access type to another.
        rows = [""] * len(pids)
    return list(zip(pids, rows))


def run_fuser(paths):
    """Query fuser once per path (see ACCESS_ROW_RE comment for why), return
    {path: [(pid, access_code), ...]} for paths that have any holder."""
    if not paths:
        return {}
    results = {}
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as ex:
        found = ex.map(_fuser_verbose_one, paths)
        for path, entries in zip(paths, found):
            if entries:
                results[path] = entries
    return results


def run_fuser_mount(mountpoint):
    return _fuser_pids(["-m", mountpoint])


def mount_fstype(path):
    """fstype if `path` is exactly a mount target per /proc/mounts, else
    None. More reliable than os.path.ismount(), which misses bind mounts
    (same st_dev as the parent)."""
    try:
        with open("/proc/mounts") as f:
            fstype = None
            for line in f:
                parts = line.split()
                if len(parts) >= 3 and parts[1] == path:
                    fstype = parts[2]
    except OSError:
        return None
    return fstype


def proc_info(pid):
    try:
        with open(f"/proc/{pid}/comm") as f:
            comm = f.read().strip()
    except OSError:
        comm = "?"
    try:
        with open(f"/proc/{pid}/cmdline", "rb") as f:
            raw = f.read()
        parts = (p.decode(errors="replace") for p in raw.split(b"\0") if p)
        cmdline = " ".join(parts)
    except OSError:
        cmdline = ""
    try:
        uid = os.stat(f"/proc/{pid}").st_uid
        user = pwd.getpwuid(uid).pw_name
    except (OSError, KeyError):
        user = "?"
    return comm, cmdline or comm, user


class Holder:
    def __init__(self, pid):
        self.pid = pid
        self.comm, self.cmdline, self.user = proc_info(pid)
        self.files = []
        self.whole_mount = False

    def add_file(self, path, access):
        self.files.append((path, access))


def discover(directory, depth):
    """Return {pid: Holder} for everything using `directory`."""
    holders = {}

    def get(pid):
        if pid not in holders:
            holders[pid] = Holder(pid)
        return holders[pid]

    paths = collect_paths(directory, depth)
    for path, entries in run_fuser(paths).items():
        for pid, access in entries:
            get(pid).add_file(path, access)

    if mount_fstype(directory) is not None:
        for pid in run_fuser_mount(directory):
            h = get(pid)
            if not h.files:
                h.whole_mount = True

    # drop our own dirbusy process if it somehow shows up (e.g. cwd == DIR)
    holders.pop(os.getpid(), None)
    return holders


def print_holders(holders, directory):
    if not holders:
        print(f"Nothing appears to be using {directory}.")
        return
    print(f"Processes using {directory}:\n")
    ordered = sorted(holders.values(), key=lambda h: h.pid)
    for i, h in enumerate(ordered, start=1):
        print(f"  [{i}] pid {h.pid}  user {h.user}  {h.comm}")
        if h.cmdline and h.cmdline != h.comm:
            print(f"        cmd: {h.cmdline}")
        if h.whole_mount and not h.files:
            print(
                "        holds: somewhere on the mounted filesystem "
                "(use --depth to locate it)"
            )
        for path, access in h.files:
            print(f"        holds: {path}  ({describe_access(access)})")
        print()


def kill_pids(pids, sig=signal.SIGTERM):
    ok, failed = [], []
    for pid in pids:
        try:
            os.kill(pid, sig)
            ok.append(pid)
        except ProcessLookupError:
            ok.append(pid)  # already gone
        except PermissionError:
            failed.append(pid)
    return ok, failed


def confirm(prompt, default_yes=False):
    suffix = " [Y/n] " if default_yes else " [y/N] "
    try:
        ans = input(prompt + suffix).strip().lower()
    except EOFError:
        return default_yes
    if not ans:
        return default_yes
    return ans in ("y", "yes")


def cmd_list(args):
    directory = resolve_dir(args.dir)
    holders = discover(directory, args.depth)
    print_holders(holders, directory)
    return 0 if not holders else 1


def do_kill(holders, pids, signum, assume_yes, label):
    if not pids:
        return
    names = ", ".join(f"{p} ({holders[p].comm})" for p in pids if p in holders)
    sig_name = signal.Signals(signum).name
    if not assume_yes and not confirm(f"Send {sig_name} to {label}: {names}?"):
        print("Skipped.")
        return
    ok, failed = kill_pids(pids, signum)
    if ok:
        print(f"Signalled: {', '.join(str(p) for p in ok)}")
    if failed:
        pids_str = ", ".join(str(p) for p in failed)
        eprint(f"Permission denied for: {pids_str} (try sudo?)")


def cmd_kill(args):
    directory = resolve_dir(args.dir)
    holders = discover(directory, args.depth)
    print_holders(holders, directory)
    if not holders:
        return 0

    signum = signal.SIGKILL if args.signal == "KILL" else signal.SIGTERM

    if args.all:
        do_kill(
            holders, list(holders.keys()), signum, args.yes,
            "all listed processes",
        )
        return 0
    if args.pid:
        do_kill(holders, args.pid, signum, args.yes, "selected pids")
        return 0

    ordered = sorted(holders.values(), key=lambda h: h.pid)
    while True:
        try:
            choice = input(
                "Kill which? (numbers comma-separated, 'a'=all, 'q'=quit): "
            ).strip()
        except EOFError:
            print()
            return 0
        if choice in ("q", "quit", ""):
            return 0
        if choice in ("a", "all"):
            do_kill(
                holders, [h.pid for h in ordered], signum, args.yes,
                "all listed processes",
            )
            return 0
        pids = []
        valid = True
        for tok in choice.split(","):
            tok = tok.strip()
            if not tok.isdigit() or not (1 <= int(tok) <= len(ordered)):
                eprint(f"Invalid selection: {tok!r}")
                valid = False
                break
            pids.append(ordered[int(tok) - 1].pid)
        if not valid:
            continue
        do_kill(holders, pids, signum, args.yes, "selected processes")
        return 0


def unmount(directory, lazy):
    fstype = mount_fstype(directory)
    if fstype and "fuse" in fstype:
        cmd = ["fusermount", "-u"]
        if lazy:
            cmd.append("-z")
        cmd.append(directory)
    else:
        cmd = ["umount"]
        if lazy:
            cmd.append("-l")
        cmd.append(directory)

    proc = subprocess.run(cmd, stderr=subprocess.PIPE, text=True)
    if proc.returncode == 0:
        print(f"Unmounted {directory}.")
        return True
    eprint(f"Unmount failed ({' '.join(cmd)}): {proc.stderr.strip()}")
    return False


def cmd_unmount(args):
    directory = resolve_dir(args.dir)

    if mount_fstype(directory) is None:
        eprint(
            f"{directory} is not currently a mountpoint - nothing to unmount "
            "(it may already be unmounted)."
        )
        return 1

    while True:
        holders = discover(directory, args.depth)
        if not holders:
            break
        print_holders(holders, directory)
        ordered = sorted(holders.values(), key=lambda h: h.pid)
        try:
            choice = input(
                "[k]ill one, [a]ll, [r]escan, [u]nmount anyway, [q]uit: "
            ).strip().lower()
        except EOFError:
            print()
            return 1

        if choice in ("q", "quit"):
            return 1
        if choice in ("u", "unmount"):
            break
        if choice in ("r", "rescan", ""):
            continue
        if choice in ("a", "all"):
            do_kill(
                holders, [h.pid for h in ordered], signal.SIGTERM, args.yes,
                "all listed processes",
            )
            time.sleep(0.5)
            continue
        if choice in ("k", "kill"):
            try:
                sel = input("Which number(s)? ").strip()
            except EOFError:
                print()
                continue
            pids = []
            valid = True
            for tok in sel.split(","):
                tok = tok.strip()
                if not tok.isdigit() or not (1 <= int(tok) <= len(ordered)):
                    eprint(f"Invalid selection: {tok!r}")
                    valid = False
                    break
                pids.append(ordered[int(tok) - 1].pid)
            if valid:
                do_kill(
                    holders, pids, signal.SIGTERM, args.yes,
                    "selected processes",
                )
                time.sleep(0.5)
            continue
        eprint("Unrecognized choice.")

    print(f"{directory} looks clear, unmounting...")
    return 0 if unmount(directory, args.lazy) else 1


def build_parser():
    parser = argparse.ArgumentParser(
        prog="dirbusy",
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    def add_common(p):
        p.add_argument("dir", help="directory or mountpoint to inspect")
        p.add_argument(
            "--depth",
            type=int,
            default=DEFAULT_DEPTH,
            help=(
                "how many levels deep to inspect file-by-file "
                f"(default: {DEFAULT_DEPTH})"
            ),
        )

    p_list = sub.add_parser(
        "list", help="show processes/files keeping DIR busy"
    )
    add_common(p_list)

    p_kill = sub.add_parser("kill", help="kill processes keeping DIR busy")
    add_common(p_kill)
    p_kill.add_argument(
        "--all", action="store_true",
        help="kill every process found, no prompt",
    )
    p_kill.add_argument(
        "--pid", type=int, action="append",
        help="kill this pid (repeatable), no prompt",
    )
    p_kill.add_argument(
        "--signal", choices=["TERM", "KILL"], default="TERM",
        help="signal to send (default: TERM)",
    )
    p_kill.add_argument(
        "-y", "--yes", action="store_true", help="don't ask for confirmation"
    )

    p_umount = sub.add_parser("unmount", help="kill blockers then unmount DIR")
    add_common(p_umount)
    p_umount.add_argument(
        "--lazy", action="store_true",
        help="lazy unmount (-z/-l) as a last resort",
    )
    p_umount.add_argument(
        "-y", "--yes", action="store_true", help="don't ask before killing"
    )

    return parser


def main():
    args = build_parser().parse_args()
    if args.command == "list":
        sys.exit(cmd_list(args))
    elif args.command == "kill":
        sys.exit(cmd_kill(args))
    elif args.command == "unmount":
        sys.exit(cmd_unmount(args))


if __name__ == "__main__":
    main()
