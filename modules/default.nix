{
  conch,
  config,
  inputs,
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

in
{
  options = {
    systems = mkOption {
      type = with lib.types; listOf (strMatching "[a-z0-9_]+-[a-z0-9]+");
      # default should generally cover as many standard systems as possible
      default = lib.systems.flakeExposed;
      description = "Systems to generate attributes for";
    };

    packages = mkOption {
      type = with lib.types; functionTo (attrsOf package);
      default = _: { };
      apply = conch.applySystemsWithGenerator conch.genericGenerator;
    };

    devShells = mkOption {
      type = with lib.types; attrsOf (functionTo (submodule ./shell.nix));
      default = { };
      apply = conch.applySystemsWithGenerator (
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
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
            config = shell { inherit system pkgs; };
            mkShell = if config.mkShell != null then config.mkShell else pkgs.mkShell;
          in
          mkShell (applyShell config)
        )
      );
    };

    formatter = mkOption {
      type = with lib.types; nullOr (functionTo package);
      default = null;
      apply =
        formatters:
        if formatters == null then
          { }
        else
          conch.applySystemsWithGenerator conch.genericGenerator formatters;
    };
  };

  config._module.args.conch = {
    applySystemsWithGenerator =
      maker: value: listToAttrs (map (system: nameValuePair system (maker system value)) config.systems);
    genericGenerator =
      system: maker:
      maker {
        inherit system;
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      };
  };
}
