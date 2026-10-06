{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.nur-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.voicestudio
  ];
}