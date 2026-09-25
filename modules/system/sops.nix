{ inputs, ... }: {
  flake.aspects.base.nixos = { pkgs, lib, config, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    # Install CLI tools for managing secrets
    environment.systemPackages = [
      pkgs.sops
      pkgs.age
      pkgs.ssh-to-age
    ];

    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/home/${config.var.username}/.config/sops/age/keys.txt";
      };

      secrets = {
        sshAuthorizedKey = {
          neededForUsers = true;
        };
        githubSshKey = {
          path = "/home/${config.var.username}/.ssh/id_ed25519";
          owner = config.var.username;
          mode = "0600";
        };
      };
    };
  };
}
