#!/bin/bash
echo "Switching home-manager to .#kleind flake"

# Run nixos-rebuild switch with --flake option, pipe output to tee
home-manager switch --flake .#kleind | tee >(grep -E '\[.+\]|^building ') &

# Capture the background process ID
background_pid=$!

# Wait for the background process to finish
wait "$background_pid"

# Check the exit code
if [[ $? -eq 0 ]]; then
  echo "home-manager rebuild successful."
else
  echo "Rebuild failed. See detailed errors in the terminal output."
fi

# Remove temporary captured output (optional)
# rm /dev/stderr
