# Includes the Java version recommended by the Fabric team
# and tools commonly used with Fabric (such as Gradle)
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    conch = {
      url = "github:mibmo/conch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { conch, ... }:
    conch.load [ "x86_64-darwin" "x86_64-linux" ] ({ ... }: {
      development.minecraft.fabric.enable = true;
    });
}
