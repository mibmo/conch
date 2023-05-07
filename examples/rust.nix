{
  inputs.conch.url = "github:mibmo/conch";
  outputs = { conch, ... }:
    conch.load [
      "aarch64-darwin"
      "riscv64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ]
      ({ ... }: {
        shell = "rust";
      });
}
