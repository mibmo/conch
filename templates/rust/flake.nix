{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    conch-rust = {
      url = "github:mibmo/conch-rust";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        conch.follows = "conch";
        rust-overlay.follows = "rust-overlay";
      };
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ conch, ... }:
    conch.load (
      { pkgs, ... }:
      {
        imports = [
          inputs.conch-rust.conchModules.rust
        ];

        rust.enable = true;

        shell.packages = with pkgs; [
          pkg-config
          openssl
        ];
      }
    );
}
