let
  # Joins a list of attributes 
  joinAttrs = builtins.foldl' (l: r: l // r) { };

  # @TODO: write documentation
  mergeFields = fields: l: r:
    joinAttrs
      (builtins.map (attr: { "${attr}" = l.${attr} // r.${attr}; })
        fields);

  fold = fields: maker: inputs:
    builtins.foldl'
      (mergeFields fields)
      (joinAttrs (builtins.map (field: { ${field} = { }; }) fields))
      (builtins.map maker inputs);

  lib = { inherit joinAttrs mergeFields fold; };
in
lib
