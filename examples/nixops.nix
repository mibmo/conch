# A bunch of tools for Devops (with Nix!)
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { conch, ... }:
    conch.load [
      "x86_64-darwin"
      "x86_64-linux"
    ]
      ({ ... }: {
        operations = {
          terranix.enable = true;
          morph.enable = true;
          nixos-anywhere.enable = true;
          nixops = {
            enable = true;
            unstable = true;
          };
        };
      });
}
