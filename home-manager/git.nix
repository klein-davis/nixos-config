{ pkgs, ... }: 
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "klein-davis";
        email = "49421694+klein-davis@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };
}
