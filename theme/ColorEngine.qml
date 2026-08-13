pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.theme
import "./themes/"

Singleton {
    id: root

    property bool isDark: false
    property real wallpaperBrightness: 0.0
    property color textOnWallpaper: isDark ? Qt.lighter(Style.textPrimary, 1) : Qt.lighter(Style.textPrimary, 1)
    property color accentOnWallpaper: Qt.lighter(Style.primary, ((isDark ? 1.2 : (1 + wallpaperBrightness - 0.3))))

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
            brightnessProc.command = ["magick", path, "-gravity", "center", "-crop", "40x40%+0+0", "+repage", "-resize", "1x1!", "-format", "%[fx:mean]", "info:"];
            brightnessProc.running = true;
        }
    }

    function withAlpha(baseColor, alpha = 1): color {
        let c = Qt.color(baseColor);
        return Qt.rgba(c.r, c.g, c.b, c.a * (1 - alpha));
    }

    onWallpaperBrightnessChanged: {
        root.isDark = root.wallpaperBrightness < 0.5;
    }

    Connections {
        target: Matugen

        function onWallPathChanged() {
            analyzeWallpaper(Matugen.wallPath);
        }
    }
}
