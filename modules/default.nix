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
  inherit (lib.lists)
    all
    head
    tail
    uniqueStrings
    ;
  inherit (lib.options) mkOption;
  inherit (lib.strings)
    concatStringsSep
    escapeShellArg
    makeLibraryPath
    typeOf
    ;
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
      apply = uniqueStrings;
    };

    apps = mkOption {
      type = with lib.types; attrsOf (attrsOf lib.conch.types.app);
      default = { };
    };

    checks = mkOption {
      type = with lib.types; either (attrsOf (attrsOf package)) (functionTo (attrsOf package));
      default = { };
      apply = conch.attrsOrApplySystemsWithGenerator conch.genericGenerator;
    };

    devShells = mkOption {
      # this convulted type w/ check is needed to represent `either (attrsOf t1) (attrsOf t2)`, as the nix module system doesn't seem to be able to properly type-check it at eval-time otherwise and degenerates into `attrsOf t1`
      type =
        lib.types.addCheck
          (with lib.types; attrsOf (either (attrsOf package) (functionTo (submodule ./shell.nix))))
          (
            x:
            let
              values = map typeOf (attrValues x);
              first = head values;
            in
            x == { } || all (e: e == first) (tail values)
          )
        // {
          # use description of emulated type
          inherit ((with lib.types; either (attrsOf (attrsOf package)) (functionTo (submodule ./shell.nix))))
            description
            ;
        };
      default = { };
      apply =
        value:
        if value == { } then
          { }
        else if isFunction (head (attrValues value)) then
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
                  inputsFrom = attrValues (config.packages.${system} or { });
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

    hydraJobs = mkOption {
      type = with lib.types; attrsOf (attrsOf lib.conch.types.derivation);
      default = { };
    };

    nixosConfigurations = mkOption {
      type = with lib.types; attrsOf lib.conch.types.nixosConfiguration;
      default = { };
    };

    nixosModules = mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          attrs
          lib.types.path
          (functionTo attrs)
        ]);
    };

    overlays = mkOption {
      type = with lib.types; attrsOf lib.conch.types.overlay;
      default = { };
    };

    packages = mkOption {
      type = with lib.types; either (attrsOf (attrsOf package)) (functionTo (attrsOf package));
      default = { };
      apply = conch.attrsOrApplySystemsWithGenerator conch.genericGenerator;
    };

    templates = mkOption {
      type =
        let
          template.options = {
            path = mkOption {
              type = lib.types.path;
            };
            description = mkOption {
              type = lib.types.str;
            };
          };
        in
        with lib.types;
        attrsOf (submodule template);
      default = { };
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
