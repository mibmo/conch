{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    conch = {
      url = "github:mibmo/conch/modularity";
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
