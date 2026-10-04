{
  flake.aspects.base.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Game Launchers
      lutris          # Multi-platform gaming launcher (Wine, DOSBox, RetroArch, etc.)
      heroic          # Native GOG, Epic Games, and Amazon Games launcher
      cartridges      # GTK4 unified game library (imports from Steam, Lutris, Heroic, etc.)
    ];
  };
}
