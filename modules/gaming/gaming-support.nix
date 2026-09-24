{
  flake.aspects.base.nixos = { pkgs, ... }: {
    # Enable kernel modules for controller support
    boot.kernelModules = [
      "uinput"      # User input module for virtual devices
      "hid_nintendo" # Nintendo Switch Pro Controller and Joy-Cons support
      "xpad"        # Xbox controller support
    ];

    # Hardware configuration for controller support
    hardware = {
      # Enable Steam hardware udev rules (includes controller support)
      steam-hardware.enable = true;

      # Enable xpadneo for better Xbox controller support (especially for wireless)
      xpadneo.enable = true;
    };

    # Additional udev rules for controller permissions and configuration
    services.udev.extraRules = ''
      # Nintendo Switch Pro Controller over USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666", TAG+="uaccess"

      # Nintendo Switch Pro Controller over Bluetooth
      KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0666", TAG+="uaccess"

      # Nyxi Wizard 2 Controller (appears as Switch Pro Controller)
      # Special rules to ensure back buttons are properly exposed to Steam Input
      SUBSYSTEM=="input", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", ENV{ID_INPUT_JOYSTICK}=="1", TAG+="steam-controller"
      SUBSYSTEM=="input", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", ENV{ID_INPUT_JOYSTICK}=="1", ENV{STEAM_INPUT_ENABLE}="1"
      SUBSYSTEM=="input", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", ENV{ID_INPUT_JOYSTICK}=="1", RUN+="${pkgs.coreutils}/bin/chmod 666 /dev/input/event%n"

      # Nintendo Switch Joy-Con (L)
      KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2006", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="*057E:2006*", MODE="0666", TAG+="uaccess"

      # Nintendo Switch Joy-Con (R)
      KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2007", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="*057E:2007*", MODE="0666", TAG+="uaccess"

      # Nintendo Switch Joy-Con Charging Grip
      KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="200e", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="*057E:200E*", MODE="0666", TAG+="uaccess"

      # Xbox One Controller over USB
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02dd", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b00", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b05", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b13", MODE="0666", TAG+="uaccess"

      # Xbox Series X|S Controller
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b20", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b21", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b22", MODE="0666", TAG+="uaccess"

      # Xbox 360 Controller
      KERNEL=="hidraw*", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666", TAG+="uaccess"

      # Flydigi Vader 4 Pro Controller (dinput mode)
      KERNEL=="hidraw*", ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2412", MODE="0666", TAG+="uaccess"
      SUBSYSTEM=="input", ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2412", ENV{ID_INPUT_JOYSTICK}=="1", TAG+="steam-controller"
      SUBSYSTEM=="input", ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2412", ENV{ID_INPUT_JOYSTICK}=="1", ENV{STEAM_INPUT_ENABLE}="1"
      SUBSYSTEM=="input", ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2412", ENV{ID_INPUT_JOYSTICK}=="1", RUN+="${pkgs.coreutils}/bin/chmod 666 /dev/input/event%n"

      # Ultimate 2 2.4GHz/Dongle and Bluetooth
      KERNEL=="hidraw*", ATTRS{idProduct}=="6012", ATTRS{idVendor}=="2dc8", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", KERNELS=="2DC8:6012", MODE="0660", TAG+="uaccess"

      # Generic rule for all game controllers
      SUBSYSTEM=="input", ATTRS{name}=="*Controller*", MODE="0666", TAG+="uaccess"
      SUBSYSTEM=="input", ATTRS{name}=="*Gamepad*", MODE="0666", TAG+="uaccess"
      SUBSYSTEM=="input", ATTRS{name}=="*Joy-Con*", MODE="0666", TAG+="uaccess"
    '';

    # System packages for gaming support
    environment.systemPackages = with pkgs; [
      # Gaming tools
      gamescope # Gaming-focused Wayland compositor
      mangohud # MangoHud

      protonup-qt # Proton-GE and other compatibility tool installer
      protontricks # ProtonTricks

      wine # Wine
      winetricks # Winetricks
      wine-wayland # Wine Wayland

      scanmem # Cheat Engine

      # SDL2 with controller support
      SDL2

      # Joystick testing and calibration tools
      jstest-gtk
      evtest

      # Controller mapping tool
      antimicrox
    ];

    # Enable joystick support in the kernel
    boot.kernelParams = [
      "usbhid.quirks=0x057e:0x2009:0x80000000"  # Fix for Switch Pro Controller
    ];
  };
}
