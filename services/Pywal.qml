pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var colors: ({})
    property var special: ({})
    property string wallpaper: ""

    Process {
        id: pywalReader
        command: ["cat", Quickshell.env("HOME") + "/.cache/wal/colors.json"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(this.text);

                    root.colors = data.colors;
                    root.special = data.special;
                    root.wallpaper = data.wallpaper;

                    root.colorsChanged();
                    root.specialChanged();
                    root.wallpaperChanged();

                } catch(e) {
                    console.error("❌ JSON Parsing failed: " + e);
                }
            }
        }
    }

    Process {
        id: pywalRunner
        command: ["wal", "-i", "", "-s", "-n"]

        onExited: code => {
            if (code === 0) {
                root.reload();
            } else {
                console.error("❌ Pywal exited with error code: " + code);
            }
        }
    }

    function reload() {
        pywalReader.running = true;
    }

    function generateColors(wallpaperPath) {
        pywalRunner.command[2] = wallpaperPath;
        pywalRunner.running = true;
    }

    Component.onCompleted: {
        root.reload();
    }
}
