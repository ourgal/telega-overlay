self: super:
with super.lib;
with builtins;
let
  getAttributesFromJSON = json: {
    inherit (json) version;
    src = super.fetchFromGitHub {
      inherit (json) owner repo rev sha256;
    };
  };
  getAttributesFromJSONFile = jsonFile:
    getAttributesFromJSON (fromJSON (readFile jsonFile));

  tdlib = super.tdlib.overrideAttrs (_:
    (getAttributesFromJSONFile ../repos/unstable/tdlib.json));
  telegaOverride = old: {
      buildInputs = (remove super.tdlib old.buildInputs) ++ [ tdlib ];
  } // (getAttributesFromJSONFile ../repos/unstable/telega.json);

  stable-tdlib = super.tdlib.overrideAttrs (_:
    (getAttributesFromJSONFile ../repos/stable/tdlib.json));
  telegaStableOverride = old: {
      buildInputs = (remove super.tdlib old.buildInputs) ++ [ stable-tdlib ];
  } // (getAttributesFromJSONFile ../repos/stable/telega.json);
in {
  emacsPackagesFor = emacs: (
    (super.emacsPackagesFor emacs).overrideScope' (eself: esuper: {
      melpaPackages.telega = esuper.melpaPackages.telega.overrideAttrs telegaOverride;
      melpaStablePackages.telega = esuper.melpaStablePackages.telega.overrideAttrs telegaStableOverride;
      telega = esuper.telega.overrideAttrs telegaStableOverride;
    }));
}
