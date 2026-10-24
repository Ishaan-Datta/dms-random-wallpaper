import QtCore
import QtQuick
import Qt.labs.folderlistmodel
import qs.Common
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool finished: false
    readonly property string defaultDirectory: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/wallpapers"
    readonly property string wallpaperDirectory: {
        const configuredDirectory = pluginData?.wallpaperDirectory || "";
        return configuredDirectory.trim() || defaultDirectory;
    }
    readonly property url wallpaperDirectoryUrl: "file://" + wallpaperDirectory.split("/").map(part => encodeURIComponent(part)).join("/")

    function cleanFilePath(path) {
        return path ? path.toString().replace(/^file:\/\//, "") : "";
    }

    function tryApplyWallpaper() {
        if (finished || !SessionData._hasLoaded || wallpaperModel.status !== FolderListModel.Ready)
            return;

        finished = true;

        if (wallpaperModel.count === 0) {
            console.warn("RandomWallpaperDaemon: No supported images found in", wallpaperDirectory);
            return;
        }

        const index = Math.floor(Math.random() * wallpaperModel.count);
        const path = cleanFilePath(wallpaperModel.get(index, "filePath"));
        if (!path) {
            console.warn("RandomWallpaperDaemon: Failed to resolve the selected wallpaper path");
            return;
        }

        console.info("RandomWallpaperDaemon: Selected", path);
        SessionData.setWallpaper(path);
    }

    Connections {
        target: SessionData

        function onLoaded() {
            root.tryApplyWallpaper();
        }
    }

    FolderListModel {
        id: wallpaperModel

        folder: root.wallpaperDirectoryUrl
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        caseSensitive: false
        showFiles: true
        showDirs: false
        showHidden: false
        showDotAndDotDot: false

        onStatusChanged: {
            if (status === FolderListModel.Ready)
                Qt.callLater(root.tryApplyWallpaper);
        }
        onCountChanged: {
            if (status === FolderListModel.Ready)
                Qt.callLater(root.tryApplyWallpaper);
        }
    }

    Component.onCompleted: Qt.callLater(tryApplyWallpaper)
}
