[issues]: https://github.com/mibmo/conch/issues
[issues-new]: https://github.com/mibmo/conch/issues/new

# conch 🐚
Leveraging the power of Nix for powerful environment-specific shells
that are made to suit your project.

Have a backend you're developing in Rust? No problem.
Need to work with CAD?.
Need to work with CAD? No problem.

## Usage
Setting up a generic environment for working with Rust is as simple as 
placing a `flake.nix` at the root of your project directory.
```nix
{
    inputs.conch.url = "github:mibmo/conch";
    outputs = { conch }:
        conch.loadShell "x86_64-linux" "rust" { };
}
```

## Environments
A full list of available environments and their options

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
- `loadShell` shorthand that supports multiple systems, e.g. `conch.loadShell ["aarch64-darwin riscv-linux"] "go"`
