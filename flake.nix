{
  description = "Environments tailored to your projects' needs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # don't break library if `nixpkgs` is overridden (as it may well be!)
    nixpkgs-lib.url = "github:nixos/nixpkgs/nixpkgs-unstable?dir=lib";
  };

  outputs =
    inputs@{ ... }:
    let
      lib = import ./lib { inherit inputs; };

      systems = [
        "aarch64-darwin"
        "riscv64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      inherit (lib.conch) load;
    }
    // lib.conch.load systems ({ pkgs, system, ... }: { });
}
