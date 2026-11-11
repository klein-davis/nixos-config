{ pkgsBundle, ... }: 
{
  home.packages = with pkgsBundle.pkgs-stable; [
    (discord.override { 
      withVencord = true; 
    })
  ];
}