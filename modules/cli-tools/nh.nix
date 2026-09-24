{
  flake.aspects.base.nixos = { pkgs, ... }: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 5";
      };
      flake = "/home/tiizzel/mangoNix";
    };

    environment.systemPackages = with pkgs;  [
      nix-output-monitor
      nvd
    ];
    environment.variables = {
      NH_FLAKE = "/home/tiizzel/mangoNix";
      NH_OS_FLAKE = "/home/tiizzel/mangoNix";
      NH_HOST_FLAKE = "/home/tiizzel/mangoNix"; 
    };
  };
}
