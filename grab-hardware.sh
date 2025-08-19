echo Getting hardware_config

echo Removing current hardware config
rm "./nixos-native/hardware-configuration.nix"

echo Copying hardware_config from /etc/nixos
sudo cp "/etc/nixos/hardware-configuration.nix" "./nixos-native/hardware-configuration.nix"

echo Hardware-config has been loaded
