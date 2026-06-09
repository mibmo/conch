[issues]: https://github.com/mibmo/conch/issues
[issues-new]: https://github.com/mibmo/conch/issues/new
[search]: https://mibmo.github.io/conch/search
[module-python]: https://github.com/mibmo/conch-python
[module-rust]: https://github.com/mibmo/conch-rust
[template-python]: https://github.com/mibmo/conch/tree/main/templates/python
[template-rust]: https://github.com/mibmo/conch/tree/main/templates/rust

# conch 🐚
Nix module system for configuring your flakes and dev shells.

## Usage
The entrypoint is the `conch.configure` function which takes a module.

In general usage consists simply of adding Conch to your flake inputs and calling `conch.configure`, then entering the environment with `nix develop` -- but take a look instead at the examples for a _much_ clearer picture.

> [!important]
> Conch's nixpkgs input should follow your own!
> Otherwise things may break or in general just not work as expected.
> The templates follow best practices and should (generally) be referred to.

## Examples
### Node with pnpm
This example shows passing a _"function module"_ into `conch.load`, just as you would when creating modules or in general configuring NixOS.
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { conch, ... }:
    conch.configure {
      devShells.default =
        { pkgs, ... }:
        {
          aliases.hello = "echo hello from ${pkgs.stdenv.hostPlatform.system}";
          packages = with pkgs; [
            nodejs
            pnpm
          ];
        };
    };
}
```

### Setting flake outputs
Since the flake outputs consist entirely of calling `conch.load`, it's responsible for the body, so thus setting outputs (like e.g. the `packages`) is done through module options.
This example shows making packages available as you would normally.
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { conch, ... }:
    conch.configure {
      packages =
        { pkgs, ... }:
        rec {
          default = pkgs.hello;
          hello = default;
        };
      formatter = { pkgs, ... }: pkgs.nixfmt-tree;
    };
}
```

> [!warning]
> It is _not_ recommended to try merging an attribute set with the output of `conch.configure`.
> It'll probably work, but it's mighty fragile.
> At the very least, use [`recursiveUpdate`](https://noogle.dev/f/lib/attrsets/recursiveUpdate) if you do decide to go this route.

> [!tip]
> To configure per-system values, consider using an if expression or the following pattern;
> ```nix
> <option> =
>   { system, ... }:
>   let
>     value = {
>       <system1> = <value1>;
>       <system2> = <value2>;
>     }
>     .${system} or <default>;
>   in
>   {
>     <shared_config> = <shared>;
>     <per_system> = value;
>   }
> ```
> You can also just write the option as you normally would with flakes, e.g.
> ```nix
> <option> = {
>   <system1> = <value1>;
>   <system2> = <value2>;
> }
> ```

## Modules
The [options search][search] isn't quite there yet, so for now you'll have to scour the source code.
Start with the `modules` directory.

## Templates
To get started quickly, use any of the available templates with `nix flake init --template=github:mibmo/conch#<template>`.
- [`python`][template-python]: Python 3 using the [`conch-python`][module-python] module.
- [`rust`][template-rust]: Rust setup using the [`conch-rust`][module-rust] module. Allows configuring targets, components/profiles, and toolchains.

### Todo!
These are some templates and/or modules that'll hopefully get made eventually;
- something that integrates with `ipetkov/crane` and provides a solid starting point.
- a modern web setup - that is, with (p)npm and all the necessary tooling.
- bevy template (this is actually what originally inspired this project, as it was particularly tricky to set up on NixOS at the time)
- leptos template(s)

## Missing something?
Open an [issue][issues-new]!

## Contributing
Conch is far from complete and the internals are likely to change a lot, but contributions are always welcome! _(especially of the module variety!)_
