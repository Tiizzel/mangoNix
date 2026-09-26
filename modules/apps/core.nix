{
  flake.aspects.base.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      mcp-nixos
      jq
      wl-clipboard
      cliphist
      wl-clip-persist
      fuzzel
    ];
  };
}
