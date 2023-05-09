{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, nixos-generators } @ inputs: let
    lib = nixpkgs.lib;
  in {
    moduleLists = {
      # A set of package to have in the installer iso
      installer = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            # Everyday helpful packages
            pkgs.vim
            pkgs.curl
            pkgs.wget
            pkgs.git
            pkgs.ripgrep
            pkgs.fd

            # Partition management
            disko.packages.x86_64-linux.disko

          ] ++

          # Scripts for each disk layout in disks/
          (let
            filesWithTypes = builtins.readDir ./disks;
            files = lib.mapAttrsToList (name: _type: name) filesWithTypes;
          in builtins.concatMap
            (file:
              let
                nameWithoutNixSuffix = lib.removeSuffix ".nix" file;
              in [
                (pkgs.writeScriptBin
                  "disko-${nameWithoutNixSuffix}-create"
                  (disko.lib.create (import ./disks/${file} {}))
                )
                (pkgs.writeScriptBin
                  "disko-${nameWithoutNixSuffix}-mount"
                  (disko.lib.mount (import ./disks/${file} {}))
                )
              ]
            ) files);

          # Enable flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
        })
      ];

      # Minimal testing machine
      argon = [
        # Disk partitions
        # Use lib.mkForce so that the disko config overrides the
        # definitions from nixos-generators
        disko.nixosModules.disko
        (disko.lib.config (import ./disks/argon.nix {}))

        ({ pkgs, ... }: {
          # Bootloader stuff
          boot.loader.grup = {
            enable = true;
            version = 2;
            efiSupport = true;
            device = "/dev/sda";
          };

          # System version
          system.stateVersion = "23.05"

          # Enable ssh
          services.openssh.enable = true;
          # systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

          # Passwordless sudo
          security.sudo.wheelNeedsPassword = false;

          # Add all wheel group users to trusted users
          nix.settings.trusted-users = [ "root" "@wheel" ];

          # Create a user
          users.users.server = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZF+j6HGldFqQdp+CaPaYKGMsFpUsk49jqhb7VtdUvn giodamelio@cadmium"
            ];
          };

          # Some random packages
          environment.systemPackages = [
            pkgs.vim
            pkgs.curl
            pkgs.wget
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
          ];
        })
      ];
    };

    nixosConfigurations = {
      argon = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = self.moduleLists.argon;
      };
    };

    packages.x86_64-linux = {
      isoInstaller = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "install-iso";
        modules = self.moduleLists.installer;
      };
    };
  };
}
