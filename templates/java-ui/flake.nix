{
  description = "Java UI conch template";

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
      ({ pkgs, ... }: {
        development.java.enable = true;
        packages = [ pkgs.javaPackages.openjfx19 ];
      });
}
