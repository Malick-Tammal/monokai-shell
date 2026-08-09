pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import "./themes/"

Singleton {
    id: root

    property bool isDark: false
    property real wallpaperBrightness: 0.0
    property color textOnWallpaper: isDark ? Qt.lighter(Matugen.colors.primary, wallpaperBrightness * 8) : Qt.lighter(Matugen.colors.primary, wallpaperBrightness * 4)
    property color accentOnWallpaper: Qt.lighter(Matugen.colors.primary, ((isDark ? 1.2 : (1 + wallpaperBrightness))))

    function withAlpha(baseColor, alpha) {
        let c = Qt.color(baseColor);
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

    Process {
        id: brightnessProc
        command: ""
        running: false

        stdout: SplitParser {
            onRead: data => {
                let val = parseFloat(data.trim());
                if (!isNaN(val)) {
                    root.wallpaperBrightness = val;
                }
            }
        }
    }

    function analyzeWallpaper(path) {
        if (path) {
            brightnessProc.command = ["magick", path, "-resize", "1x1!", "-format", "%[fx:mean]", "info:"];
            brightnessProc.running = true;
        }
    }

    onWallpaperBrightnessChanged: {
        root.isDark = root.wallpaperBrightness < 0.47;
    }

    Connections {
        target: Matugen

        function onWallPathChanged() {
            analyzeWallpaper(Matugen.wallPath);
        }
    }
}
