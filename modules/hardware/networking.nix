{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    networking.networkmanager.enable = true;
    environment.systemPackages = [
      pkgs.networkmanagerapplet
      pkgs.localsend
    ];

    # Fix Realtek RTL8168/8111 Ethernet watchdog tx timeout (rtl_rxtx_empty_cond == 0)
    boot.kernelParams = [
      "pcie_aspm=off"
    ];
  };
}
