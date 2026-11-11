{ pkgsBundle, ... }:
let
  pkgs-silly = pkgsBundle.pkgs-stable;
  vcv-rack = pkgs-silly.vcv-rack.overrideAttrs (old: rec {
    name = "VCV-Rack";
    version = "2.5.2";

    src = pkgs-silly.fetchurl {
      url = "https://vcvrack.com/downloads/RackFree-${version}-lin-x64.zip";
      sha256 = "sha256-bHu6XzzPj+Zndx3dJhnGoX+Etd/THTaD9WwlPidinKE=";
    };

    nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs-silly.unzip pkgs-silly.autoPatchelfHook ];
    buildInputs = old.buildInputs ++ [
      pkgs-silly.stdenv.cc.cc.lib
      pkgs-silly.stdenv.cc.libc
    ];

    unpackPhase = ''
      unzip $src
    '';

    # dontPatch alone only skips applying these - Nix still has to fetch
    # each one as a build input, and fix-segfault-on-linux.patch is fetched
    # from a GitHub PR diff URL that now 404s. None of upstream's patches
    # are relevant anyway since src above is a prebuilt binary, not the
    # source they patch.
    patches = [];
    prePatch = "";
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    doInstallCheck = false;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cd Rack2Free
      cp Rack $out/bin
      mkdir -p $out/lib
      cp libRack.so $out/lib
      mkdir $out/Rack2Free
      cp -r * $out/Rack2Free
      mkdir -p $out/share/vcv-rack
      cp -r cacert.pem Core.json res $out/share/vcv-rack
      cp -r *.vcvplugin $out/share/vcv-rack || true
      cp -r LICENSE*.html $out/share/vcv-rack || true
      cp -r template.vcv $out/share/vcv-rack || true
      cp -r template-plugin.vcv $out/share/vcv-rack || true
      runHook postInstall
    '';

    postInstall = (if old ? postInstall then old.postInstall else "") + ''
      wrapProgram $out/bin/Rack --set RACK_SYSTEM_DIR $out
    '';

    meta.description = "Open-source virtual modular synthesizer -- free edition";
    meta.mainProgram = "Rack";
  });
in
{
  home.packages = [ vcv-rack ];
  home.sessionVariables.RACK_SYSTEM_DIR = "${vcv-rack.outPath}";
}