# Nix overlay with telega.el
Overlay for nix that provides stable and unstable version of
[telega.el](https://github.com/zevlg/telega.el) emacs package with
telega-server built with compatible tdlib version.

## No longer maintained
I no longer use nixos so I cannot maintain this and have disabled 
actions in this repository.  If you want to use this then you can
fork repository and enable github actions in it, it should continue
to work in the future assuming dockerfile that is used here to obtain
commit hash is not changed significantly enough for script to break.

## Contents of the overlay
- `emacsPackages.melpaPackages.telega` - latest version of telega with
  telega-server built with compatible tdlib version
- `emacsPackages.melpaStablePackages.telega` - stable version of
  telega with telega-server built with compatible tdlib version
- `emacsPackages.telega` - same as
  `emacsPackages.melpaStablePackages.telega`

## Using overlay
### With NixOS configuration
```nix
{
  # ...
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/ipvych/telega-overlay/archive/main.tar.gz;
    }))
  ];
  environment.systemPackages = with pkgs; [
    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
      # for unstable telega
      epkgs.melpaPackages.telega
      # for stable telega
      # epkgs.telega
     ]))
  ];
  # ...
}
```
### With NixOS configuration using flakes
Add telega overlay as input to flake.nix like so
```nix
{
  # ...
  telega-overlay = {
    url = "github:ipvych/telega-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # ...
}
```
Then in configuration you can use in like so
```nix
{
  # ...
  nixpkgs.overlays = [ inputs.telega-overlay.overlay ];
  environment.systemPackages = with pkgs; [
    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
      # for unstable telega
      epkgs.melpaPackages.telega
      # for stable telega
      # epkgs.telega
     ]))
  ];
  # ...
}
```
## FAQ
### How packages are updated?
CI job is automaticaly run every day that runs `update` script in each
repo folder. This job retrives version hashes and data for stable and
unstable releases and writes them in approprite `.json` files that are
then used by overlay.

## Credits
Scipts for updating repos and general structure of repo were adapted
from [emacs-overlay](https://github.com/nix-community/emacs-overlay)
repository.
