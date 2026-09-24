{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    fonts.packages = with pkgs; [
      font-awesome
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      fira
      material-icons
      roboto
      corefonts
    ];
  };
}
