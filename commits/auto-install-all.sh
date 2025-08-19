#!/bin/bash
echo "Installing all of nixos"
echo "Enabling flakes"
echo ""

cd "./enable-flakes"
bash "enable-flakes.sh"
wait

cd ..
cd "./nixos-config-main"

bash "./grab-hardware.sh"
wait
bash "./nixos-switch-flake.sh"
wait
bash "./home-manager-switch-flake.sh"
wait

cd ..

echo "Complete"