{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    conch-fenix.url = "github:mibmo/conch-fenix";
  };

  outputs =
    inputs@{ conch, ... }:
    conch.load {
      imports = [
        inputs.conch-fenix.conchModules.rust
      ];

      rust.enable = true;
    };
}
