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
      argon = [
        disko.nixosModules.disko
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
      iso = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "iso";
        modules = self.moduleLists.argon;
      };
      proxmox-lxc = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "proxmox-lxc";
        modules = self.moduleLists.argon;
      };
    };
  };
}
