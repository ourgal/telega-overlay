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

  stable-tdlib = super.tdlib.overrideAttrs (_:
    (getAttributesFromJSONFile ../repos/stable/tdlib.json));
in {
  emacsPackagesFor = emacs: (
    (super.emacsPackagesFor emacs).overrideScope (eself: esuper:
    let
        telegaOverride = old: {
          buildInputs = (remove super.tdlib old.buildInputs) ++ [ tdlib ];
          packageRequires = old.packageRequires or [ ] ++ [ eself.rainbow-identifiers ];
        } // (getAttributesFromJSONFile ../repos/unstable/telega.json);
        telegaStableOverride = old: {
          buildInputs = (remove super.tdlib old.buildInputs) ++ [ stable-tdlib ];
        } // (getAttributesFromJSONFile ../repos/stable/telega.json);
    in
    {
        melpaPackages = esuper.melpaPackages // {
            telega = esuper.melpaPackages.telega.overrideAttrs telegaOverride;
        };
        melpaStablePackages = esuper.melpaStablePackages // {
            telega = esuper.melpaStablePackages.telega.overrideAttrs telegaStableOverride;
        };
        # Stable package is too outdated
        telega = eself.melpaPackages.telega;
    }));
}
