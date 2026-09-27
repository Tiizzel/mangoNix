{ pkgs, ... }: {
  # Packages installed specifically on this host
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here, for example:
    # lact             # GPU control / overclocking
    # nvtopPackages.amd
  ];
}
