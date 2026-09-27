{
  flake.aspects.base.nixos = { config, ... }: {
    # Enable official NordVPN daemon and graphical client service
    services.nordvpn.enable = true;

    # Allow primary user to manage connections without sudo
    users.users.${config.var.username}.extraGroups = [ "nordvpn" ];
  };
}
