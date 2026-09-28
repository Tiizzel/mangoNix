{ config, ... }: {
  var = {
    # Primary user account name
    username = "tiizzel";

    # Primary user's real or display name
    name = "Tiizzel";

    # Git user details
    gitUsername = "Tiizzel";
    gitEmail = "adamdominik1996@gmail.com";

    # System hostname
    hostname = "nixos";

    # System timezone
    timezone = "Europe/Berlin";

    # System keyboard layout
    keyboardLayout = "de";

    # Primary GPU driver profile: "amd" | "nvidia" | "intel" | "vm" | "generic"
    gpu = "amd";

    # Linux kernel variant: "cachyos-bore" | "zen" | "latest" | "default"
    kernel = "cachyos-bore";

    # Bootloader: "grub" | "systemd-boot"
    bootloader = "grub";

    # MangoWM monitor configuration rules
    monitorRules = [
      "name:DP-1, width:5120, height:1440, refresh:240, x:0, y:0, rr:0, vrr:1, hdr:2, hdr_min_lum: 0.05, hdr_max_lum: 800"
    ];

    # Enable SOPS encrypted secrets management
    enableSops = true;
  };
}
