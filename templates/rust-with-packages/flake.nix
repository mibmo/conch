{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      conch,
      crane,
      rust-overlay,
      ...
    }:
    let
      rustFor = pkgs: pkgs.rust-bin.stable.latest;
      craneFor = pkgs: (crane.mkLib pkgs).overrideToolchain (pkgs': (rustFor pkgs').default);
    in
    conch.configure {
      systems = [
        "x86_64-linux"
      ];
      nixpkgs.overlays = [ (import rust-overlay) ];
      devShells.default =
        { pkgs, ... }:
        {
          mkShell = (craneFor pkgs).devShell;
          environment = {
            "RUST_SRC_PATH" = "${(rustFor pkgs).rust-src}/lib/rustlib/src/rust/library";
            "RUST_LOG" = "my_crate=trace";
          };
          packages = with pkgs; [
            openssl
            pkg-config
          ];
        };
      packages =
        { pkgs, ... }:
        let
          crane = craneFor pkgs;
        in
        {
          default = crane.buildPackage {
            src = crane.cleanCargoSource ./.;
            strictDeps = true;
          };
        };
      formatter =
        { pkgs, ... }:
        pkgs.treefmt.withConfig {
          runtimeInputs = with pkgs; [
            nixfmt
            (rustFor pkgs).rustfmt
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
