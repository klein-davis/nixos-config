{ pkgs, ... }: 
{
  programs.git = {
    enable = true;
    
    userName  = "klein-davis";
    userEmail = "49421694+klein-davis@users.noreply.github.com";
    
    extraConfig = { 
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };

  home.packages = [ pkgs.gh pkgs.git-lfs ];
}
