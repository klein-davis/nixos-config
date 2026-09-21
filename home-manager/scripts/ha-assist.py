"""ha-assist - talk to a Home Assistant Assist conversation agent from a
terminal.

SETUP
  1. Get a long-lived access token:
       Home Assistant web UI -> click your user profile (bottom left) ->
       Security tab -> "Long-Lived Access Tokens" -> Create Token.
       Copy it immediately; HA only shows it once.
  2. Export it along with your HA base URL, e.g. in ~/.zshrc or ~/.bashrc:
       export HA_URL="http://homeassistant.local:8123"
       export HA_TOKEN="eyJhbGciOi..."
  Alternatively, create ~/.config/ha-assist/config (ini format):
       [default]
       url = http://homeassistant.local:8123
       token = eyJhbGciOi...

       [work]
       url = https://ha.example.com
       token = eyJhbGciOi...
  Select a non-default section with --profile work. Env vars, if set,
  always win over the config file.

USAGE
  ha-assist "turn off the office lights"   # one-shot: send, print, exit
  ha-assist                                # interactive REPL (assist>)
                                            # 'exit'/'quit'/Ctrl-D to leave

  In the REPL, all commands share one conversation_id so follow-ups like
  "turn it off" resolve the same way they would in the web UI's Assist chat.
  One-shot invocations each get a fresh conversation_id.

FLAGS
  -l, --language LANG   language code sent to Assist (default: en)
  -k, --insecure        skip TLS certificate verification
  --cacert PATH         path to a custom CA bundle for HTTPS verification
  -v, --verbose         print the raw HTTP request/response
  -p, --profile NAME    config file section to use (default: "default")
"""

import argparse
import configparser
import json
import os
import ssl
import sys
import urllib.error
import urllib.request
import uuid
from pathlib import Path

CONFIG_PATH = Path.home() / ".config" / "ha-assist" / "config"

TOKEN_HELP = (
    "Get one from the Home Assistant web UI: click your profile (bottom "
    "left) -> Security tab -> \"Long-Lived Access Tokens\" -> Create Token."
)


def supports_color():
    if os.environ.get("NO_COLOR"):
        return False
    return sys.stdout.isatty()


class Color:
    def __init__(self, enabled):
        self.enabled = enabled

    def wrap(self, code, text):
        if not self.enabled:
            return text
        return f"\033[{code}m{text}\033[0m"

    def prompt(self, text):
        return self.wrap("1;36", text)  # bold cyan

    def response(self, text):
        return self.wrap("32", text)  # green

    def error(self, text):
        return self.wrap("1;31", text)  # bold red

    def dim(self, text):
        return self.wrap("2", text)


def load_config(profile):
    """Read ~/.config/ha-assist/config, if present, for the profile."""
    if not CONFIG_PATH.exists():
        return {}
    parser = configparser.ConfigParser()
    try:
        parser.read(CONFIG_PATH)
    except configparser.Error as e:
        msg = f"Warning: could not parse {CONFIG_PATH}: {e}"
        print(msg, file=sys.stderr)
        return {}
    if not parser.has_section(profile):
        return {}
    return dict(parser.items(profile))


def resolve_config(args):
    """Env vars win over the config file; --profile picks the section."""
    file_cfg = load_config(args.profile)
    url = os.environ.get("HA_URL") or file_cfg.get("url")
    token = os.environ.get("HA_TOKEN") or file_cfg.get("token")

    if not url or not token:
        missing = []
        if not url:
            missing.append("HA_URL")
        if not token:
            missing.append("HA_TOKEN")
        print(
            "Error: missing configuration: " + ", ".join(missing),
            file=sys.stderr,
        )
        print(file=sys.stderr)
        print("Set them as environment variables, e.g.:", file=sys.stderr)
        print(
            '  export HA_URL="http://homeassistant.local:8123"',
            file=sys.stderr,
        )
        print(
            '  export HA_TOKEN="<your long-lived access token>"',
            file=sys.stderr,
        )
        print(file=sys.stderr)
        print(TOKEN_HELP, file=sys.stderr)
        print(file=sys.stderr)
        print(
            f"Or create {CONFIG_PATH} with a [{args.profile}] section "
            "containing url = ... and token = ... (see --help).",
            file=sys.stderr,
        )
        sys.exit(1)

    return url.rstrip("/"), token


def build_ssl_context(args):
    if args.cacert:
        return ssl.create_default_context(cafile=args.cacert)
    if args.insecure:
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        return ctx
    return None


class AssistError(Exception):
    """Raised for problems reaching or authenticating with Home Assistant."""


def send_command(
    url, token, text, language, conversation_id, ssl_context, verbose
):
    endpoint = f"{url}/api/conversation/process"
    payload = json.dumps(
        {
            "text": text,
            "language": language,
            "conversation_id": conversation_id,
        }
    ).encode("utf-8")

    if verbose:
        print(f"--> POST {endpoint}", file=sys.stderr)
        print(f"--> {payload.decode('utf-8')}", file=sys.stderr)

    request = urllib.request.Request(
        endpoint,
        data=payload,
        method="POST",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
    )

    try:
        with urllib.request.urlopen(
            request, context=ssl_context, timeout=30
        ) as resp:
            body = resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        if e.code == 401:
            raise AssistError(
                "401 Unauthorized - your HA_TOKEN was rejected. "
                "Check that the token is correct and hasn't been "
                "revoked."
            ) from e
        raise AssistError(
            f"HTTP {e.code} {e.reason} from Home Assistant:\n{body}"
        ) from e
    except urllib.error.URLError as e:
        raise AssistError(
            f"Could not reach {url} ({e.reason}). "
            "Check HA_URL and that Home Assistant is running and "
            "reachable."
        ) from e
    except TimeoutError as e:
        raise AssistError(
            f"Timed out waiting for a response from {url}."
        ) from e

    if verbose:
        print(f"<-- {body}", file=sys.stderr)

    try:
        data = json.loads(body)
    except json.JSONDecodeError as e:
        raise AssistError(
            f"Home Assistant returned non-JSON output:\n{body}"
        ) from e

    return data


def extract_speech(data):
    try:
        return data["response"]["speech"]["plain"]["speech"]
    except (KeyError, TypeError):
        return None


def print_result(data, color):
    speech = extract_speech(data)
    if speech is not None:
        print(color.response(speech))
    else:
        print(color.dim("(unexpected response shape, raw JSON below)"))
        print(json.dumps(data, indent=2, sort_keys=True))


def main():
    parser = argparse.ArgumentParser(
        prog="ha-assist",
        description=(
            "Talk to a Home Assistant Assist conversation agent from "
            "the terminal."
        ),
        epilog=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "text", nargs="*", help="command to send; omit for REPL mode"
    )
    parser.add_argument(
        "-l", "--language", default="en", help="language code (default: en)"
    )
    parser.add_argument(
        "-k",
        "--insecure",
        action="store_true",
        help="skip TLS certificate verification",
    )
    parser.add_argument(
        "--cacert", help="path to a custom CA bundle for HTTPS verification"
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="print raw request/response",
    )
    parser.add_argument(
        "-p", "--profile", default="default", help="config file profile to use"
    )
    args = parser.parse_args()

    url, token = resolve_config(args)
    ssl_context = build_ssl_context(args)
    color = Color(supports_color())

    if args.text:
        text = " ".join(args.text)
        conversation_id = f"ha-assist-{uuid.uuid4()}"
        try:
            data = send_command(
                url,
                token,
                text,
                args.language,
                conversation_id,
                ssl_context,
                args.verbose,
            )
        except AssistError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)
        print_result(data, color)
        return

    conversation_id = f"ha-assist-{uuid.uuid4()}"
    print("Home Assistant Assist - type a command, or 'exit'/'quit' to leave.")
    while True:
        try:
            line = input(color.prompt("assist> "))
        except EOFError:
            print()
            break
        except KeyboardInterrupt:
            print()
            continue

        text = line.strip()
        if not text:
            continue
        if text in ("exit", "quit"):
            break

        try:
            data = send_command(
                url,
                token,
                text,
                args.language,
                conversation_id,
                ssl_context,
                args.verbose,
            )
        except AssistError as e:
            print(color.error(f"Error: {e}"), file=sys.stderr)
            continue
        print_result(data, color)


if __name__ == "__main__":
    main()
