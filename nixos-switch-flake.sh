#!/bin/bash
echo "Switching NixOS to .#nixos flake"

# Run nixos-rebuild switch with --flake option, pipe output to tee
sudo nixos-rebuild switch --flake .#nixos | tee >(grep -E '\[.+\]|^building ') &

# Capture the background process ID
background_pid=$!

# Wait for the background process to finish
wait "$background_pid"

# Check the exit code
if [[ $? -eq 0 ]]; then
  echo "NixOS rebuild successful."
else
  echo "Rebuild failed. See detailed errors in the terminal output."
fi

# Remove temporary captured output (optional)
# rm /dev/stderr
