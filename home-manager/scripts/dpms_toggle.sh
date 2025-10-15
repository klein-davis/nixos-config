#!/usr/bin/env bash

# Check DPMS status (false = ON) for any monitor
if $@hyprctl monitors -j | $@jq -e 'any(.[]; .dpmsStatus == false)' > /dev/null; then
    # If ON, turn OFF
    $@hyprctl dispatch dpms off
else
    # If OFF, turn ON
    $@hyprctl dispatch dpms on
fi