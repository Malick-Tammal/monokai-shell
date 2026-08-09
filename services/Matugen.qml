pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

Singleton {
    id: root

    property var colors: ({})
    property var base16: ({})
    property var palettes: ({})
    property string mode
    property string wallPath
    property bool isDarkMode

    function _delUnderscore(key): void {
        let parts = key.split("_");
        let camel = parts[0] + parts.slice(1).map(function (p) {
            return p.charAt(0).toUpperCase() + p.slice(1);
        }).join("");

        if (key.startsWith("on_")) {
            camel = "color" + camel.charAt(0).toUpperCase() + camel.slice(1);
        }
        return camel;
    }

    function _applyColors(data): void {
        let colors = data.colors;
        let base16 = data.base16;

        if (!colors || !base16) {
            console.error("Matugen: invalid JSON structure");
            return;
        }

        let newColors = {};

        for (let key in colors) {
            let entry = colors[key];
            if (entry && entry.dark && entry.dark.color) {
                let propName = _delUnderscore(key);
                newColors[propName] = entry.dark.color;
            }
        }

        root.colors = newColors;
        root.base16 = data.base16;
        root.palettes = data.palettes;
        root.mode = data.mode;
        root.wallPath = data.image;
        root.isDarkMode = data.is_dark_mode;
    }

    Process {
        id: matugenRunner
        command: ["matugen", "image", "", "--json", "hex", "--prefer", "saturation"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim())
                    return;
                try {
                    let data = JSON.parse(text);
                    root._applyColors(data);
                    matugenCacher.setText(text);
                } catch (e) {
                    console.error("Matugen JSON parsing failed: " + e);
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.error("Matugen exited with code: " + exitCode);
            }
        }
    }

    Connections {
        target: WalliService

        function onCurrentWallPathChanged() {
            matugenRunner.command[2] = WalliService.currentWallPath;
            matugenRunner.running = true;
        }
    }

    FileView {
        id: matugenCacher
        path: Dirs.cacheFolder + "colors.json"
        preload: true

        onLoaded: root._loadCached()
        onLoadFailed: error => console.warn("Matugen: no cached colors (" + error + ")")
        // onSaved: console.log("Matugen: cached colors written")
        onSaveFailed: error => console.error("Matugen: failed to write cache: " + error)
    }

    function _loadCached() {
        const text = matugenCacher.text();
        if (!text.trim())
            return;
        try {
            root._applyColors(JSON.parse(text));
            // console.log("Matugen: applied cached colors from " + matugenCacher.path);
        } catch (e) {
            console.error("Matugen: cached JSON parsing failed: " + e);
        }
    }

    function generateColors(wallpaperPath) {
        matugenRunner.command[2] = wallpaperPath;
        matugenRunner.running = true;
    }
}
