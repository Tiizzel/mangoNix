{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, ... }: {
    # LM Studio — GUI app for browsing, downloading & chatting with local LLMs
    environment.systemPackages = [
      pkgs.lmstudio
    ];
  };
}
