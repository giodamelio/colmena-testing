{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators } @ inputs: let
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
          ] ++

          # Quick script to quickly download my dotfiles
          # TODO: update this when we actually put my real system here
          [
            (pkgs.writeScriptBin
              "installer-clone-dotfiles"
              ''
              git clone https://github.com/giodamelio/colmena-testing
              cd colmena-testing/
              ''
            )
          ];

          # Add all the SSH public keys from my Github to the installer
          users.users.nixos = {
            openssh.authorizedKeys.keyFiles = [
              (builtins.fetchurl {
                url = "https://github.com/giodamelio.keys";
                sha256 = "1waqkfprkchajc8p4i67b4rf9pgxqcmlh4fhgdk3wwqdlc71qq91";
              })
            ];
          };

          # Enable flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
        })
      ];

      # Minimal testing machine
      argon = [
        ({ pkgs, ... }: {
          # Bootloader stuff
          boot.loader.grub = {
            enable = true;
            version = 2;
            efiSupport = true;
            device = "/dev/sda";
          };

          # System version
          system.stateVersion = "23.05";

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
