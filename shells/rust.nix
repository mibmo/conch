{ mkConch, fenix, rust-analyzer-nightly }:
mkConch {
  pname = "rust";
  packages = [
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
  ];
}
