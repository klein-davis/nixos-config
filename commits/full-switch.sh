bash "commit.sh"
wait

cd "./nixos-config-main"

bash "./nixos-switch-flake.sh"
wait
bash "./home-manager-switch-flake.sh"
wait

cd ..

echo "Complete"