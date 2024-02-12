{
  description = "Rust conch template";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { conch, ... }:
    conch.load [
      "aarch64-darwin"
      "riscv64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ]
      ({ ... }: {
        development.rust = {
          enable = true;
          profile = "stable";
        };
      });
}
