[issues]: https://github.com/mibmo/conch/issues
[issues-new]: https://github.com/mibmo/conch/issues/new

# conch 🐚
Leveraging the power of Nix for powerful environment-specific shells
that are made to suit your project.

Have a backend you're developing in nightly Rust? _no problem, there's an environment for that._
Need to work with CAD? _sure thing! try the `cad` environment._
Making 3D graphics? _great! pull in the `graphics3d` environment._

Doing something entirely different?
specify no environment (or the closest to your usecase) and set your packages with the `packages` attribute.

## Usage
Setting up a generic environment for working with Rust is as simple as 
placing a `flake.nix` at the root of your project directory.
```nix
{
    inputs.conch.url = "github:mibmo/conch";
    outputs = { conch, ... }:
        conch.load ["x86_64-linux"] ({ ... }: {
            shell = "rust";
        });
}
```

Entering the environment is then as simple as running `nix develop`.

Ready to copy example flakes are available in the examples directory.

## Environments
A full list of available environments and their options

### Nix
Nix language server

### Rust
Rust nightly with rust-analyzer

### Go (TODO)

### Clojure (TODO)
Clojure with Leiningen

### Kubernetes (TODO)
The full Kubernetes suite with third-party tools.
- helm
- kubeseal

### Missing something?
Create an [issue][issues-new] and we can look into it!

# Contributing
Conch is far from complete and the internals are likely to change a lot, but contributions are always welcome!

### TODO
- CI to test shells, i.e. does the `rust` conch work on `riscv-linux` and the `go` on `aarch64-darwin`?
- set `name = "conch-${pname}"` after overrides and only if `name` is unset
