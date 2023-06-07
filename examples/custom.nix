{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { conch, ... }:
    conch.load [ "x86_64-darwin" "x86_64-linux" ] ({ pkgs }: {
      packages = with pkgs; [
        hello
      ];
    });
}
