{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { conch, rust-overlay, ... }:
    conch.configure {
      systems = [
        "aarch64-darwin"
        "riscv64-linux"
        "x86_64-linux"
      ];
      nixpkgs.overlays = [ (import rust-overlay) ];
      devShells.default =
        { pkgs, ... }:
        {
          environment."RUST_LOG" = "my_crate=trace";
          packages = with pkgs; [
            openssl
            pkg-config
            rust-bin.stable.latest.default
          ];
        };
      formatter =
        { pkgs, ... }:
        pkgs.treefmt.withConfig {
          runtimeInputs = with pkgs; [
            nixfmt
            rustfmt
          ];
          settings = {
            excludes = [
              "*.lock"
              ".gitignore"
            ];
            formatter = {
              nixfmt = {
                command = "nixfmt";
                includes = [ "*.nix" ];
              };
              rustfmt = {
                command = "rustfmt";
                includes = [ "*.rs" ];
              };
            };
          };
        };
    };
}
