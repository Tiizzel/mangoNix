{ config, ... }: {
  var = {
    # Primary user account name
    username = "tiizzel";

    # Primary user's real or display name
    name = "Tiizzel";

    # System hostname
    hostname = "nixos";

    # System timezone
    timezone = "Europe/Berlin";

    # System keyboard layout
    keyboardLayout = "de";

    # Primary GPU driver profile: "amd" | "nvidia" | "intel" | "vm" | "generic"
    gpu = "amd";

    # Enable SOPS encrypted secrets management
    enableSops = true;
  };
}
