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
      nixpkgs.overlays = [
        (self: super: {
          hello = super.hello.overrideAttrs (
            final: prev: {
              patches = prev.patches or [ ] ++ [
                (builtins.toFile "hello-message.patch" ''
                  diff '--color=auto' -urpN old/src/hello.c new/src/hello.c
                  --- old/src/hello.c	2026-01-17 20:24:39.000000000 +0100
                  +++ new/src/hello.c	2026-06-09 19:10:47.953160544 +0200
                  @@ -145,7 +145,7 @@ main (int argc, char *argv[])
                   #endif
                   
                     /* Having initialized gettext, get the default message. */
                  -  greeting_msg = _("Hello, world!");
                  +  greeting_msg = _("Hello, conch!");
                   
                     /* Even exiting has subtleties.  On exit, if any writes failed, change
                        the exit status.  The /dev/full device on GNU/Linux can be used for
                '')
              ];
              doCheck = false;
            }
          );
        })
      ];
      packages =
        { pkgs, ... }:
        {
          # this references `pkgs`, so uses patched version
          inherit (pkgs) hello;
        };
      devShells.default =
        { pkgs, ... }:
        {
          # same here! try entering the dev shell!
          packages = with pkgs; [ hello ];
          hook = "hello";
        };
    };
}
