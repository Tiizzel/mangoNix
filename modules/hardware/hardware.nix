{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    hardware = {
      sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
        disabledDefaultBackends = [ "escl" ];
      };
      enableRedistributableFirmware = true;
      keyboard.qmk.enable = true;
    };
    programs.solaar.enable = true;
  };
}
