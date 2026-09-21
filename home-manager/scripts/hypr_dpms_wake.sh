#!/usr/bin/env bash
# Force DPMS on/off, or toggle.
#
# Hyprland 0.56's Lua config dropped the old "dispatch dpms toggle" CLI
# syntax (dispatch now takes a single Lua expression), so this goes through
# `hyprctl eval` calling the actual hl.dsp.dpms() Lua API instead.

set -euo pipefail

action="${1:-toggle}"
source_label="${2:-unknown}"
reload() { hyprctl eval "hl.dispatch(hl.dsp.force_renderer_reload())" >/dev/null; }
dpms_status() { hyprctl monitors -j | jq -r 'if (.[0].dpmsStatus | type) == "boolean" then (.[0].dpmsStatus | tostring) else "?" end'; }

log="$HOME/.local/state/hypr-dpms-wake.log"
mkdir -p "$(dirname "$log")"

before=$(dpms_status)

# hl.dsp.dpms() doesn't reliably no-op when asked for the state the panel is
# already in - observed live, dispatching "off" while already off turned the
# panel back on, and dispatching "on" while already on turned it back off.
# Skip the dispatch entirely when it would be redundant so hypridle's
# on-timeout/on-resume calls can't fight an out-of-band change (e.g. a
# manual toggle keybind) by re-flipping an already-correct state.
if { [ "$action" = "on" ] && [ "$before" = "true" ]; } || { [ "$action" = "off" ] && [ "$before" = "false" ]; }; then
  after="$before"
else
  # A dpms state change doesn't always get a fresh frame pushed to the panel
  # on its own (the panel can end up logically on/off-matching but physically
  # not repainted) - force a renderer reload on both sides of the dispatch so
  # the compositor always re-commits a full frame to match the new state.
  reload
  hyprctl eval "hl.dispatch(hl.dsp.dpms('${action}'))" >/dev/null
  reload
  after=$(dpms_status)
fi

printf '%s source=%s action=%s before=%s after=%s\n' \
  "$(date +'%Y-%m-%d %H:%M:%S.%3N')" "$source_label" "$action" "$before" "$after" >>"$log"
