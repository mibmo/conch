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
    let
      rustFor = pkgs: pkgs.rust-bin.stable.latest;
    in
    conch.configure {
      systems = [
        "aarch64-darwin"
        "riscv64-linux"
        "x86_64-linux"
      ];
      nixpkgs.overlays = [ (import rust-overlay) ];
      devShells.default =
        { pkgs, ... }:
        let
          rust = rustFor pkgs;
        in
        {
          environment = {
            "RUST_SRC_PATH" = "${rust.rust-src}/lib/rustlib/src/rust/library";
            "RUST_LOG" = "my_crate=trace";
          };
          packages = with pkgs; [
            openssl
            pkg-config
            rust.default
          ];
        };
      formatter =
        { pkgs, ... }:
        let
          rust = rustFor pkgs;
        in
        pkgs.treefmt.withConfig {
          runtimeInputs = with pkgs; [
            nixfmt
            rust.rustfmt
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
