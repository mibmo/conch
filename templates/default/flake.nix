{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { conch, ... }:
    conch.configure {
      systems = [
        "aarch64-darwin"
        "riscv64-linux"
        "x86_64-linux"
      ];
      packages =
        { pkgs, ... }:
        {
          inherit (pkgs) hello;
        };
      devShells.default =
        { pkgs, ... }:
        {
          aliases.run = "hello --traditiona";
          packages = with pkgs; [
            hello
          ];
        };
      formatter = { pkgs, ... }: pkgs.nixfmt-tree;
    };
}
