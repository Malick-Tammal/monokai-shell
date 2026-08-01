pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string wallsFolder: Quickshell.env("HOME") + "/Pictures/Wallpapers/"
    readonly property string cacheFolder: Quickshell.env("HOME") + "/.cache/monokai_shell/"
    readonly property string walliCacheFolder: cacheFolder + "walli_thumbs/"

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", root.cacheFolder]);
    }
}
