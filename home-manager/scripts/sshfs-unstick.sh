#!/usr/bin/env bash
# Force-clean stale sshfs mounts without ever touching the mount points
# themselves (stat/ls/cd on a dead sshfs mount is exactly what hangs).
set -u
set -o pipefail

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
LOG="$LOG_DIR/sshfs-unstick.log"
mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG"
}

notify() {
  notify-send --app-name="sshfs-unstick" "$@" 2>>"$LOG" || true
}

# /proc/mounts and /proc/self/mountinfo escape space/tab/newline/backslash
# as \040 \011 \012 \134 - printf '%b' decodes those octal escapes back to
# the real bytes. The kernel never leaves a bare backslash unescaped, so
# there's no ambiguity with printf's other backslash sequences.
decode_octal() {
  printf '%b' "$1"
}

FUSERMOUNT=""
for candidate in fusermount3 fusermount; do
  if command -v "$candidate" >/dev/null 2>&1; then
    FUSERMOUNT="$candidate"
    break
  fi
done

mountpoints=()
while read -r _src mnt fstype _rest; do
  [ "$fstype" = "fuse.sshfs" ] || continue
  mountpoints+=("$(decode_octal "$mnt")")
done </proc/mounts

if [ ${#mountpoints[@]} -eq 0 ]; then
  log "no sshfs mounts found"
  notify "sshfs-unstick" "No sshfs mounts found - nothing to do."
  exit 0
fi

log "found ${#mountpoints[@]} sshfs mount(s): ${mountpoints[*]}"

# List pids (not threads) with comm == sshfs, without touching any mount.
all_sshfs_pids() {
  local pid comm
  for pid_path in /proc/[0-9]*; do
    pid="${pid_path#/proc/}"
    comm=$(cat "$pid_path/comm" 2>/dev/null) || continue
    [ "$comm" = "sshfs" ] || continue
    [ "$(stat -c %u "$pid_path" 2>/dev/null)" = "$EUID" ] || continue
    printf '%s\n' "$pid"
  done
}

# pids whose argv contains $1 literally (decoded cmdline, NUL-separated).
sshfs_pids_for_mount() {
  local target="$1" pid comm cmdline
  for pid_path in /proc/[0-9]*; do
    pid="${pid_path#/proc/}"
    comm=$(cat "$pid_path/comm" 2>/dev/null) || continue
    [ "$comm" = "sshfs" ] || continue
    cmdline=$(tr '\0' '\n' <"$pid_path/cmdline" 2>/dev/null) || continue
    if printf '%s\n' "$cmdline" | grep -qxF "$target"; then
      printf '%s\n' "$pid"
    fi
  done
}

kill_pids() {
  local pids=("$@")
  [ ${#pids[@]} -eq 0 ] && return 0
  log "SIGTERM: ${pids[*]}"
  kill -TERM "${pids[@]}" 2>>"$LOG"
  sleep 1
  local still=()
  local p
  for p in "${pids[@]}"; do
    kill -0 "$p" 2>/dev/null && still+=("$p")
  done
  if [ ${#still[@]} -gt 0 ]; then
    log "SIGKILL: ${still[*]}"
    kill -KILL "${still[@]}" 2>>"$LOG"
  fi
}

# Resolve the /sys/fs/fuse/connections id for a mount purely from
# /proc/self/mountinfo (no path access): fuse mounts use an anon block
# device with major 0, and its minor is the connection id in sysfs.
fuse_connection_id() {
  local target="$1" major minor mm mp_raw mp
  while read -r _id _parent mm _root mp_raw _rest; do
    mp=$(decode_octal "$mp_raw")
    [ "$mp" = "$target" ] || continue
    major=${mm%%:*}
    minor=${mm##*:}
    if [ "$major" = "0" ]; then
      printf '%s\n' "$minor"
      return 0
    fi
  done </proc/self/mountinfo
  return 1
}

still_mounted() {
  local target="$1" mnt fstype
  while read -r _src mnt fstype _rest; do
    [ "$fstype" = "fuse.sshfs" ] || continue
    [ "$(decode_octal "$mnt")" = "$target" ] && return 0
  done </proc/mounts
  return 1
}

unmounted=()
failed=()

for mp in "${mountpoints[@]}"; do
  mapfile -t pids < <(sshfs_pids_for_mount "$mp")
  if [ ${#pids[@]} -eq 0 ]; then
    log "no pid matched args for '$mp', falling back to all sshfs pids"
    mapfile -t pids < <(all_sshfs_pids)
  fi
  kill_pids "${pids[@]}"

  ok=0
  if [ -n "$FUSERMOUNT" ]; then
    if timeout 5 "$FUSERMOUNT" -uz -- "$mp" 2>>"$LOG"; then
      ok=1
    else
      log "$FUSERMOUNT -uz failed for '$mp'"
    fi
  fi

  if still_mounted "$mp"; then
    if timeout 5 umount -l -- "$mp" 2>>"$LOG"; then
      ok=1
    else
      log "umount -l failed for '$mp'"
    fi
  fi

  if still_mounted "$mp" && [ -d /sys/fs/fuse/connections ]; then
    conn_id=$(fuse_connection_id "$mp") || conn_id=""
    if [ -n "$conn_id" ] && [ -w "/sys/fs/fuse/connections/$conn_id/abort" ]; then
      log "aborting fuse connection $conn_id for '$mp'"
      if echo 1 >"/sys/fs/fuse/connections/$conn_id/abort" 2>>"$LOG"; then
        timeout 5 umount -l -- "$mp" 2>>"$LOG" && ok=1
      fi
    fi
  fi

  if ! still_mounted "$mp"; then
    ok=1
  fi

  if [ "$ok" -eq 1 ]; then
    unmounted+=("$mp")
  else
    failed+=("$mp")
  fi
done

summary="Unmounted: ${#unmounted[@]}"
[ ${#unmounted[@]} -gt 0 ] && summary="$summary (${unmounted[*]})"
if [ ${#failed[@]} -gt 0 ]; then
  summary="$summary
Failed: ${failed[*]}"
fi

log "done - $summary"
notify "sshfs-unstick" "$summary"
