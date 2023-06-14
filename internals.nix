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
      (
        builtins.map
          ({ attr, input }: joinAttrs (builtins.map (field: { ${field}.${input} = attr.${field}; }) fields))
          (map (input: { attr = maker input; inherit input; }) inputs)
      );

  internals = { inherit joinAttrs mergeFields fold; };
in
internals
