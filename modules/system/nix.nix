{
  flake.aspects.base.nixos = { ... }: {
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      download-buffer-size = 200000000;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
    };
    system.stateVersion = "26.05";
  };
}
