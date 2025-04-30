{
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options.flake = mkOption {
    type = types.attrs;
    description = "Arbitrary flake configuration.";
    default = { };
  };
}
