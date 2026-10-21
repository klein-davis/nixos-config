#!/usr/bin/env bash
# Force DPMS on/off, or toggle - tracked and dispatched per monitor.
#
# Hyprland 0.56's Lua config dropped the old "dispatch dpms toggle" CLI
# syntax (dispatch now takes a single Lua expression), so this goes through
# `hyprctl eval` calling the actual hl.dsp.dpms() Lua API instead.
#
# State is read and set per monitor: reading only the first monitor (or
# dispatching to all) breaks once the monitors drift out of sync (e.g. one
# fails to wake), because every later "on"/"off"/toggle then flips the
# out-of-sync monitor the wrong way.

set -euo pipefail

action="${1:-toggle}"
source_label="${2:-unknown}"
reload() { hyprctl eval "hl.dispatch(hl.dsp.force_renderer_reload())" >/dev/null; }
# "name=true|false" per line
dpms_states() { hyprctl monitors -j | jq -r '.[] | "\(.name)=\(.dpmsStatus)"'; }

log="$HOME/.local/state/hypr-dpms-wake.log"
mkdir -p "$(dirname "$log")"

before=$(dpms_states | paste -sd' ')

# Toggle: if any monitor is on, turn everything off; otherwise turn all on.
target="$action"
if [ "$action" = "toggle" ]; then
  if dpms_states | grep -q '=true$'; then target=off; else target=on; fi
fi
want=$([ "$target" = "on" ] && echo true || echo false)

# hl.dsp.dpms() doesn't reliably no-op when asked for the state the panel is
# already in (dispatching "off" while off turns it on), so only dispatch to
# monitors that actually differ from the target.
changed=0
while IFS='=' read -r name state; do
  [ "$state" = "$want" ] && continue
  if [ "$changed" = 0 ]; then
    # Force a renderer reload on both sides so the compositor re-commits a
    # full frame to match the new state.
    reload
    changed=1
  fi
  hyprctl eval "hl.dispatch(hl.dsp.dpms({ action = '${target}', monitor = '${name}' }))" >/dev/null
done < <(dpms_states)
[ "$changed" = 1 ] && reload

after=$(dpms_states | paste -sd' ')

printf '%s source=%s action=%s before=[%s] after=[%s]\n' \
  "$(date +'%Y-%m-%d %H:%M:%S.%3N')" "$source_label" "$action" "$before" "$after" >>"$log"
