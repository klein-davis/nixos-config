{ myOptions, pkgs, ... }: {
    environment.systemPackages = [ pkgs.sshfs ];
    services.openssh = {
        enable = myOptions.enable-ssh-access;
        ports = [22];
        settings = {
        PasswordAuthentication = true;
        AllowUsers = null;
        PermitRootLogin = "yes";
        };
    };
}