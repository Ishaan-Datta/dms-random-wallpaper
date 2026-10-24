# Random Wallpaper for DMS

A [DankMaterialShell](https://danklinux.com/docs/dankmaterialshell/plugin-development)
plugin that selects a random wallpaper from a configured directory when DMS
starts.

## Features

- Runs entirely inside the Quickshell QML process
- Changes the wallpaper once when the plugin starts
- Configurable wallpaper directory
- Supports JPG, JPEG, PNG, and WebP images
- Case-insensitive, non-recursive directory scanning
- No external scripts or command-line dependencies
- Leaves the current wallpaper unchanged when no supported images are found

## Requirements

- DankMaterialShell 2.0 or newer
- A directory containing supported wallpaper images

## Nix installation

Add this repository as a flake input and pass its package to the official DMS
Home Manager module:

```nix
{
  inputs.dms-random-wallpaper.url = "github:Ishaan-Datta/dms-random-wallpaper";

  outputs = inputs@{ nixpkgs, ... }: {
    homeConfigurations.your-user = inputs.home-manager.lib.homeManagerConfiguration {
      # ...
      modules = [
        inputs.dms.homeModules.default
        ({ pkgs, ... }: {
          programs.dank-material-shell.plugins.randomWallpaperDaemon = {
            enable = true;
            src = inputs.dms-random-wallpaper.packages.${pkgs.system}.default;
          };
        })
      ];
    };
  };
}
```

## Configuration

Set the wallpaper directory from the plugin settings page, or add it directly
to `~/.config/DankMaterialShell/plugin_settings.json`:

```json
{
  "randomWallpaperDaemon": {
    "wallpaperDirectory": "/home/user/.local/share/wallpapers"
  }
}
```

The path must be absolute. It defaults to
`~/.local/share/wallpapers`. Subdirectories are not scanned.

The plugin changes the global wallpaper. Per-monitor wallpaper overrides may
continue to take precedence. Reloading, disabling and re-enabling, or updating
the plugin creates a new daemon instance and can select another wallpaper.
