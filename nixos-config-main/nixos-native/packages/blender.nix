{ pkgs, pkgsBundle, lib, myOptions, ... }: {

  environment.systemPackages = with pkgs; [
    (if myOptions.enable-nvidia-gpu then (blender.override {cudaSupport=true;}) else (blender))
  ];
}
