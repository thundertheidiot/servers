{
  description = "Flake for my servers.";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;

    deploy.nodes = {
      uwu = {
        hostname = "192.168.101.101";
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.server;
        };
      };
    };

    nixosConfigurations = let
      gen = list: (
        builtins.listToAttrs (map (name: {
            inherit name;
            value = nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
                mlib = import "${inputs.meowos}/lib" {inherit (nixpkgs) lib;};
              };
              modules = [
                (import ./hosts/${name})
                inputs.disko.nixosModules.default
                inputs.authentik-nix.nixosModules.default
                inputs.sops-nix.nixosModules.default

                {
                  imports =
                    (import ./modules)
                    ++ (let
                      i = l: map (n: "${inputs.meowos}/modules/${n}") l;
                    in
                      i [
                        "impermanence.nix"
                      ]);
                }
              ];
            };
          })
          list)
      );
    in
      gen ["server" "vps"];

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";

    meowos.url = "github:thundertheidiot/nixdots";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";

    authentik-nix.url = "github:nix-community/authentik-nix";
  };
}
