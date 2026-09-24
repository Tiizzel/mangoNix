{
  flake.aspects.base.nixos = { pkgs, config, ... }: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
      flake = config.var.dotfilesDir;
    };

    environment.systemPackages = with pkgs;  [
      nix-output-monitor
      nvd
    ];
    environment.variables = {
      NH_FLAKE = config.var.dotfilesDir;
      NH_OS_FLAKE = config.var.dotfilesDir;
      NH_HOST_FLAKE = config.var.dotfilesDir; 
    };
  };
}
