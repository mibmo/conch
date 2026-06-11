{
  conch,
  config,
  lib,
  ...
}:
let
  inherit (lib.attrsets)
    attrValues
    foldlAttrs
    listToAttrs
    mapAttrs
    nameValuePair
    ;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep escapeShellArg makeLibraryPath;
  inherit (lib.trivial) isFunction;
in
{
  imports = [
    ./nixpkgs.nix
  ];

  options = {
    systems = mkOption {
      type = with lib.types; listOf (strMatching "[a-z0-9_]+-[a-z0-9]+");
      # default should generally cover as many standard systems as possible
      default = lib.systems.flakeExposed;
      description = "Systems to generate attributes for";
    };

    packages = mkOption {
      type = with lib.types; either (attrsOf (attrsOf package)) (functionTo (attrsOf package));
      default = { };
      apply = conch.attrsOrApplySystemsWithGenerator conch.genericGenerator;
    };

    devShells = mkOption {
      type =
        with lib.types;
        either (attrsOf (attrsOf package)) (attrsOf (functionTo (submodule ./shell.nix)));
      default = { };
      apply =
        value:
        if value == { } then
          { }
        else if isFunction value then
          conch.applySystemsWithGenerator (
            system:
            let
              args = conch.makeArgs system;
              applyShell =
                shell:
                {
                  # @TODO: include formatter once it's done
                  packages = shell.packages; # ++ [ config.formatter ];
                  LD_LIBRARY_PATH = makeLibraryPath shell.libraries;
                  inputsFrom = attrValues config.packages.${system};
                  shellHook =
                    let
                      aliasCmd = foldlAttrs (
                        acc: name: value:
                        acc + "alias ${escapeShellArg name}=${escapeShellArg value};"
                      ) "" shell.aliases;
                      envCmd = foldlAttrs (
                        acc: name: value:
                        acc + "export ${escapeShellArg name}=${escapeShellArg value};"
                      ) "" shell.environment;
                    in
                    concatStringsSep "\n" (
                      [
                        aliasCmd
                        envCmd
                      ]
                      ++ shell.hooks
                      ++ [ shell.hook ]
                    );
                }
                // shell.extraOpts;
            in
            mapAttrs (
              _: shell:
              let
                config = shell args;
                mkShell = if config.mkShell != null then config.mkShell else args.pkgs.mkShell;
              in
              mkShell (applyShell config)
            )
          ) value
        else
          value;
    };

    formatter = mkOption {
      type = with lib.types; either (attrsOf (attrsOf package)) (functionTo package);
      default = { };
      apply = conch.attrsOrApplySystemsWithGenerator conch.genericGenerator;
    };
  };

  config._module.args.conch = {
    applySystemsWithGenerator =
      maker: value: listToAttrs (map (system: nameValuePair system (maker system value)) config.systems);
    attrsOrApplySystemsWithGenerator =
      maker: value: if isFunction value then conch.applySystemsWithGenerator maker value else value;
    genericGenerator = system: maker: maker (conch.makeArgs system);
    makeArgs = system: {
      inherit system lib;
      pkgs = config.nixpkgs.final.${system};
    };
  };
}
