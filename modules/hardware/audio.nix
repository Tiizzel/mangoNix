{
  flake.aspects.base.nixos = { pkgs, ... }: {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # Low-latency PipeWire server quantum configuration
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 64;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 1024;
        };
      };

      # Low-latency PulseAudio emulation configuration
      extraConfig.pipewire-pulse."92-low-latency" = {
        "context.properties" = {
          "pulse.min.req" = "32/48000";
          "pulse.default.req" = "64/48000";
          "pulse.max.req" = "1024/48000";
          "pulse.min.quantum" = "32/48000";
          "pulse.max.quantum" = "1024/48000";
        };
        "stream.properties" = {
          "node.latency" = "64/48000";
          "resample.quality" = 1;
        };
      };

      # WirePlumber low-latency ALSA node rules & prevent suspend popping
      wireplumber.extraConfig = {
        "10-alsa-low-latency" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_output.*";
                }
                {
                  "node.name" = "~alsa_input.*";
                }
              ];
              actions = {
                update-props = {
                  "audio.rate" = 48000;
                  "api.alsa.period-size" = 64;
                  "api.alsa.headroom" = 64;
                  "session.suspend-timeout-seconds" = 0; # Disable idle suspend to eliminate popping/wake delay
                };
              };
            }
          ];
        };
      };
    };

    environment.systemPackages = [ pkgs.pavucontrol ];
  };
}
