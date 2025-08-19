echo Saving old configuration to folder "Old_Configuration"
sudo mkdir "/etc/nixos/Old_Configuration"
sudo mv "/etc/nixos/configuration.nix" "/etc/nixos/Old_Configuration/configuration.nix"


echo Replacing configuration.nix
#Relative Filepath From Script Run Location
sudo cp "./configuration.nix" "/etc/nixos/configuration.nix"


echo Switching to new config
sudo nixos-rebuild switch


echo "#######################################################"
echo Flakes have been activated
