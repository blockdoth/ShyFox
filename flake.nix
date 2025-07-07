{
  description = "Firefox + ShyFox Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      shyfoxPkg = pkgs.fetchFromGitHub {
        owner = "blockdoth";
        repo = "ShyFox";
        rev = "fba147660a1b374f00e50df59b525f7c7bb5a4e5";
        sha256 = "sha256-YfPDJHoyA0tj73rnDOqI65n0bAh8hSTPnXLDEkzQVpg=";
      };
      firefoxModule = import ./firefox.nix;
    in
    {
      homeManagerModules.shyfox = firefoxModule;      
      packages.${system}.shyfox = shyfoxPkg;
      homeConfigurations.username = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          firefoxModule
        ];
      };
    };
}
