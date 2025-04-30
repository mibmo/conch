{
  config,
  lib,
  inputs,
  system,
  ...
}:
with lib;
let
  cfg = config.flake;
in
{
  options.flake = mkOption {
    type = types.attrs;
    description = lib.mdDoc "Arbitrary flake configuration.";
    default = { };
  };
}
