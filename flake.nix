{
  description = "Random wallpaper daemon plugin for DankMaterialShell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          plugin = pkgs.stdenvNoCC.mkDerivation {
            pname = "dms-plugin-random-wallpaper";
            version = "1.0.0";
            src = pkgs.lib.fileset.toSource {
              root = ./.;
              fileset = pkgs.lib.fileset.unions [
                ./RandomWallpaperDaemon.qml
                ./RandomWallpaperSettings.qml
                ./plugin.json
                ./README.md
              ];
            };

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              runHook preInstall
              mkdir -p "$out"
              cp \
                RandomWallpaperDaemon.qml \
                RandomWallpaperSettings.qml \
                plugin.json \
                README.md \
                "$out/"
              runHook postInstall
            '';

            meta = {
              description = "Set a random wallpaper when DankMaterialShell starts";
              platforms = pkgs.lib.platforms.linux;
            };
          };
        in
        {
          default = plugin;
          dmsRandomWallpaper = plugin;
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          package = self.packages.${system}.default;

          manifest =
            pkgs.runCommand "check-dms-random-wallpaper-manifest" { nativeBuildInputs = [ pkgs.jq ]; }
              ''
                jq -e '
                  .id == "randomWallpaperDaemon" and
                  .type == "daemon" and
                  .component == "./RandomWallpaperDaemon.qml" and
                  .settings == "./RandomWallpaperSettings.qml"
                ' ${./plugin.json} >/dev/null

                test -f ${./RandomWallpaperDaemon.qml}
                test -f ${./RandomWallpaperSettings.qml}
                touch "$out"
              '';

          qml =
            pkgs.runCommand "check-dms-random-wallpaper-qml" { nativeBuildInputs = [ pkgs.qt6.qtdeclarative ]; }
              ''
                qmllint \
                  --only-explicit-categories \
                  --syntax error \
                  -I ${pkgs.qt6.qtdeclarative}/lib/qt-6/qml \
                  ${./RandomWallpaperDaemon.qml} \
                  ${./RandomWallpaperSettings.qml}
                touch "$out"
              '';
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              jq
              nixfmt
              qt6.qtdeclarative
            ];
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
