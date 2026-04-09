[issues]: https://github.com/mibmo/conch/issues
[issues-new]: https://github.com/mibmo/conch/issues/new
[search]: https://mibmo.github.io/conch/search
[module-python]: https://github.com/mibmo/conch-python
[module-rust]: https://github.com/mibmo/conch-rust
[template-python]: https://github.com/mibmo/conch/tree/main/templates/python
[template-rust]: https://github.com/mibmo/conch/tree/main/templates/rust

# conch 🐚
Nix module system for configuring your dev shell.

## Usage
The entrypoint is the `conch.load` function, which takes a module and optionally a list of systems;
either call as `conch.load <module>` or `conch.load [ <system> ... ] <module>` (when omitted, the systems defaults to [`lib.systems.flakeExposed`](https://github.com/NixOS/nixpkgs/blob/96e87bd250d5f4f3447b87ab7e94689ea19e0c2a/lib/systems/default.nix#L51-L59)).

In general, usage consists of simply adding Conch to your flake inputs and calling `conch.load`, then entering the environment with `nix develop` -- but take a look instead at the examples for a _much_ clearer picture.

> [!important]
> Conch's nixpkgs input should follow your own!
> Otherwise things may break or in general just not work as expected.
> The templates follow best practices and should (generally) be referred to.

## Examples
### Python
Python has a corresponding [Conch module][module-python], imported just like any other Nix module, which provides an easier way to set up Python. (the following is taken from the [Python template][template-python])
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    conch-python.url = "github:mibmo/conch-python";
  };

  outputs =
    inputs@{ conch, ... }:
    conch.load {
      imports = [
        inputs.conch-python.conchModules.python
      ];

      python.enable = true;
    };
}
```

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

  outputs = { conch, ... }:
    conch.load  ({ pkgs, ... }: {
      shell.packages = with pkgs; [
        nodejs
        pnpm
      ];
    });
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

  outputs = { conch, ... }:
    conch.load  ({ system, pkgs, ... }: {
      flake = {
        formatter.${system} = pkgs.nixpkgs-fmt;
        packages.${system} = rec {
          default = hello;
          hello = pkgs.hello;
        };
      };
    });
}
```

All `flake` options are recursively merged across the systems, so for a systems input of `[ "x86_64-linux" "riscv64-linux" "aarch64-darwin" ]` this would be (roughly) equivalent to
```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs }: {
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages."x86_64-linux".nixpkgs-fmt;
      riscv64-linux = nixpkgs.legacyPackages."riscv64-linux".nixpkgs-fmt;
      aarch64-darwin = nixpkgs.legacyPackages."aarch64-linux".nixpkgs-fmt;
    };
    packages = {
      x86_64-linux = rec {
        default = hello;
        hello = nixpkgs.legacyPackages."x86_64-linux".hello;
      };
      riscv64-linux = rec {
        default = hello;
        hello = nixpkgs.legacyPackages."riscv64-linux".hello;
      };
      aarch64-darwin = rec {
        default = hello;
        hello = nixpkgs.legacyPackages."aarch64-darwin".hello;
      };
    };
  };
}
```

> [!note]
> It is _not_ recommended to try merging an attribute set with the output of `conch.load`.
> It'll probably work, but it's mighty fragile.
> At the very least, use [`recursiveUpdate`](https://noogle.dev/f/lib/attrsets/recursiveUpdate) if you do decide to go this route.

> [!tip]
> To do per-system configuration, consider using an if expression or the following pattern;
> ```nix
> <option> =
>   {
>     <system1> = <value1>;
>     <system2> = <value2>;
>   }
>   .${system} or <default>
> ```

## Modules
The [options search][search] isn't quite there yet, so for now you'll have to scour the source code.

## Templates
To get started quickly, use any of the available templates with `nix flake init --template=github:mibmo/conch#<template>`.
These are the available templates;
- [`python`][template-python]: Python 3 using the [`conch-python`][module-python] module.
- [`rust`][template-rust]: Rust setup using the [`conch-rust`][module-rust] module. Allow configuring targets, components/profiles, and toolchains.

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

<div style="font-size: 0.4em">
<h2>What's in the name?</h2>
<em>shell.</em>
</div>
