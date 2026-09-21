{ inputs, pkgs, ... }: {
  environment.systemPackages = with inputs.lmstudio.packages.${pkgs.stdenv.hostPlatform.system}; [
    lmstudio
    lmstudio-bionic
    lmstudio-server
  ];
}