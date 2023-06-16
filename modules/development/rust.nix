{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.development.rust;
in
{
  options.development.rust = {
    enable = mkEnableOption "rust toolchain";
    profile = mkOption {
      type = types.str;
      default = "default";
      description = mdDoc ''
        Rustup profile to use. Can be added to with `development.rust.components`.
      '';
    };
    components = mkOption {
      type = with types; listOf str;
      default = [
        "cargo"
        "clippy"
        "rustc"
        "rustfmt"
      ];
      description = mdDoc "Toolchain components to include toolchain.";
    };
    enableRustAnalyzer = mkOption {
      type = types.bool;
      default = true;
      description = mdDoc "Enable rust-analyzer";
    };
  };

  config = mkIf cfg.enable
    {
      packages =
        let
          toolchain = pkgs.fenix.${cfg.profile}.withComponents cfg.components;
          rust-analyzer = mkIf cfg.enableRustAnalyzer pkgs.rust-analyzer-nightly;
        in
        [
          toolchain
          rust-analyzer
        ];
    };
}
