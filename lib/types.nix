{ lib, ... }:
let
  inherit (builtins) match;
  inherit (lib) types mkOptionType;
  inherit (lib.options) mergeEqualOption;

  semverPattern = ''(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(([a-zA-Z-][a-zA-Z0-9-]*|[a-zA-Z0-9-]+[a-zA-Z-][a-zA-Z0-9-]*)|(0|[1-9][0-9]*))(\.(([a-zA-Z-][a-zA-Z0-9-]*|[a-zA-Z0-9-]+[a-zA-Z-][a-zA-Z0-9-]*)|(0|[1-9][0-9]*)))*)?(\+(([a-zA-Z-][a-zA-Z0-9-]*|[a-zA-Z0-9-]+[a-zA-Z-][a-zA-Z0-9-]*)|[0-9]+)(\.(([a-zA-Z-][a-zA-Z0-9-]*|[a-zA-Z0-9-]+[a-zA-Z-][a-zA-Z0-9-]*)|[0-9]+))*)?'';
in
{
  semver = mkOptionType {
    name = "semver";
    description = "semantic version";
    descriptionClass = "noun";
    check = v: types.str.check v && match semverPattern v != null;
    merge = mergeEqualOption;
  };
}
