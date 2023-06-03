{
  description = "Flake providing latest telega version and tdlib compatible with it";

  outputs = {self, nixpkgs}: {
    overlays.default = final: prev: import ./overlays final prev;
    overlay = self.overlays.default;
  };
}
