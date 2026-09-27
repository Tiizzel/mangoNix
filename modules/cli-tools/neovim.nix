{
  flake.aspects.base.nixos = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    # Enable nix-ld so Mason/Treesitter downloaded tools and LSPs run smoothly on NixOS
    programs.nix-ld.enable = true;

    environment.systemPackages = with pkgs; [
      git
      gcc
      gnumake
      unzip
      ripgrep
      fd
      wl-clipboard
      lua51Packages.luarocks
    ];
  };
}
