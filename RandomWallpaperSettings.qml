import QtCore
import QtQuick
import qs.Modules.Plugins

PluginSettings {
    id: root

    pluginId: "randomWallpaperDaemon"

    StringSetting {
        settingKey: "wallpaperDirectory"
        label: "Wallpaper directory"
        description: "Absolute path to a directory containing JPG, JPEG, PNG, or WebP images. Subdirectories are not scanned."
        placeholder: "/home/user/.local/share/wallpapers"
        defaultValue: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/wallpapers"
    }
}
