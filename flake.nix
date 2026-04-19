{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    systems,
    nixpkgs,
    ...
  }: let
    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
  in {
    packages = eachSystem (pkgs: {
      default = pkgs.stdenv.mkDerivation {
        pname = "bait-and-switch";
        version = "0.1";
        src = ./.;
        nativeBuildInputs = [pkgs.makeWrapper];
        installPhase = ''
          mkdir -p $out/share/bait-and-switch $out/bin
          cp -r main.lua conf.lua src assets $out/share/bait-and-switch/
          makeWrapper ${pkgs.love}/bin/love $out/bin/bait-and-switch \
            --add-flags "$out/share/bait-and-switch"
        '';
      };
    });

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          lua
          love
          stylua
          nodejs
        ];
        SDL_VIDEODRIVER = "";
      };
    });
  };
}
