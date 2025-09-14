{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    conch-rust.url = "github:mibmo/conch-rust";
  };

  outputs =
    inputs@{ conch, ... }:
    conch.load {
      imports = [
        inputs.conch-rust.conchModules.rust
      ];

      rust.enable = true;
    };
}
