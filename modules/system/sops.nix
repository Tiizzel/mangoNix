{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    # Install CLI tools for managing secrets
    environment.systemPackages = [
      pkgs.sops
      pkgs.age
    ];

    # sops = {
    #   defaultSopsFile = ../../secrets/secrets.yaml;
    #   age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    #   secrets.sshAuthorizedKey = { neededForUsers = true; };
    #   secrets.githubSshKey = {
    #     path = "/home/tiizzel/.ssh/id_ed25519";
    #     owner = "tiizzel";
    #     mode = "0600";
    #   };
    # };
  };
}
