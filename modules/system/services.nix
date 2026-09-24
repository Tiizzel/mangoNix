{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    services = {
      upower.enable = true; # noctalia/quickshell battery reporting
      libinput.enable = true; # Input Handling
      fstrim.enable = true; # SSD Optimizer
      gvfs.enable = true; # For Mounting USB & More
      power-profiles-daemon.enable = true;
      openssh = {
        enable = true; # Enable SSH
        settings = {
          PermitRootLogin = "no"; # Prevent root from SSH login
          PasswordAuthentication = true; # Users can SSH using keyboard and password
          KbdInteractiveAuthentication = true;
        };
        authorizedKeysFiles = [ "%h/.ssh/authorized_keys" ]
          ++ lib.optional (config.sops.secrets ? sshAuthorizedKey) config.sops.secrets.sshAuthorizedKey.path;
        ports = [22];
      };
      gnome.gnome-keyring.enable = true;
    };
  };
}
