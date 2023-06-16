[issues]: https://github.com/mibmo/conch/issues
[issues-new]: https://github.com/mibmo/conch/issues/new
[search]: https://mibmo.github.io/conch/search

# conch 🐚
Leveraging the power of Nix modules for powerful
environment-specific shells to suit your project.

## Usage
Setting up a generic environment for working with Rust is as simple as 
placing a `flake.nix` at the root of your project directory.
```nix
{
  inputs.conch.url = "github:mibmo/conch";
  outputs = { conch, ... }:
    conch.load [ "x86_64-linux" ] ({ ... }: {
      development.rust = {
        enable = true;
        profile = "complete";
      };
    });
}
```

Entering the environment by running `nix develop`.

A full list of the modules and their options are available at [mibmo.github.io/conch/search][search]

**NOTE:** Conch's nixpkgs input should follow your own!
Otherwise things may break or in general just not work as expected.
The examples follow best practices and should be referred to.

### Missing something?
Open an [issue][issues-new]!

## Contributing
Conch is far from complete and the internals are likely to change a lot,
but contributions are always welcome! *(especially of the module variety!)*
