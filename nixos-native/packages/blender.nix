{ pkgs, pkgsBundle, lib, myOptions, ... }: {

  environment.systemPackages = with pkgsBundle.pkgs-stable; [
    (if myOptions.enable-nvidia-gpu then (blender.override {cudaSupport=true;}) else (blender))
  ];
}
