{
  inputs.conch.url = "github:mibmo/conch";
  outputs = { conch, ... }:
    conch.load [ "x86_64-darwin" "x86_64-linux" ] ({ pkgs }: {
      packages = with pkgs; [
        hello
      ];
    });
}
