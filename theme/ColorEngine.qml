pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    property bool isDark: false
    property real wallpaperBrightness: 0.0
    property color textOnWallpaper: withAlpha(isDark ? Qt.lighter(pywal.special.accent, 2.0) : Qt.lighter(pywal.special.accent, 0.1),0.7)
    property color accentOnWallpaper: Qt.lighter(pywal.special.accent, ((isDark ? 1.2 : 1.1) + (1.0 - wallpaperBrightness) * 0.5))

    property var monokai_fusion: ({
            "black": "#000000",
            "white": "#FDFFF1",

            "dark9": "#060605",
            "dark8": "#0C0C0A",
            "dark7": "#11120F",
            "dark6": "#171814",
            "dark5": "#1D1E19",
            "dark4": "#282922",
            "dark3": "#33342B",
            "dark2": "#3D4035",
            "dark1": "#606453",

            "green9": "#222C18",
            "green8": "#44582F",
            "green7": "#658447",
            "green6": "#87B05E",
            "green5": "#A9DC76",
            "green4": "#BAE391",
            "green3": "#CBEAAD",
            "green2": "#DDF1C8",
            "green1": "#EEF8E4",

            "red9": "#33131B",
            "red8": "#662736",
            "red7": "#993A52",
            "red6": "#CC4E6D",
            "red5": "#FF6188",
            "red4": "#FF81A0",
            "red3": "#FFA0B8",
            "red2": "#FFC0CF",
            "red1": "#FDDDDD",

            "orange9": "#321E15",
            "orange8": "#653D29",
            "orange7": "#975B3E",
            "orange6": "#CA7A52",
            "orange5": "#FC9867",
            "orange4": "#FDAD85",
            "orange3": "#FDC1A4",
            "orange2": "#FED6C2",
            "orange1": "#FEEAE1",

            "yellow9": "#332B14",
            "yellow8": "#4C411F",
            "yellow7": "#99823D",
            "yellow6": "#CCAD52",
            "yellow5": "#FFD866",
            "yellow4": "#FFE085",
            "yellow3": "#FFE8A3",
            "yellow2": "#FFEFC2",
            "yellow1": "#FFF7E0",

            "purple9": "#2A234E",
            "purple8": "#4A4277",
            "purple7": "#6B60A0",
            "purple6": "#8B7FC9",
            "purple5": "#AB9DF2",
            "purple4": "#BCB1F5",
            "purple3": "#CDC4F7",
            "purple2": "#DDD8FA",
            "purple1": "#EEEBFC",

            "blue9": "#182C2E",
            "blue8": "#30585D",
            "blue7": "#48848B",
            "blue6": "#60B0BA",
            "blue5": "#78DCE8",
            "blue4": "#93E3ED",
            "blue3": "#AEEAF1",
            "blue2": "#C9F1F6",
            "blue1": "#E4F8FA",

            "gray9": "#0C0D0B",
            "gray8": "#181A15",
            "gray7": "#252620",
            "gray6": "#31332A",
            "gray5": "#3D4035",
            "gray4": "#606359",
            "gray3": "#84867E",
            "gray2": "#A7A9A2",
            "gray1": "#CBCCC7",
    })

    property var pywal: ({
            "colors": {
                "color0": root.monokai_fusion.dark6,
                "color1": root.monokai_fusion.red5,
                "color2": root.monokai_fusion.green5,
                "color3": root.monokai_fusion.yellow5,
                "color4": root.monokai_fusion.blue5,
                "color5": root.monokai_fusion.purple5,
                "color6": root.monokai_fusion.orange5,
                "color7": root.monokai_fusion.white,
                "color8": root.monokai_fusion.dark4,
                "color9": root.monokai_fusion.red4,
                "color10": root.monokai_fusion.green4,
                "color11": root.monokai_fusion.yellow4,
                "color12": root.monokai_fusion.blue4,
                "color13": root.monokai_fusion.purple4,
                "color14": root.monokai_fusion.orange4,
                "color15": root.monokai_fusion.white
            },

            "special": {
                "background": root.monokai_fusion.dark5,
                "foreground": root.monokai_fusion.white,
                "cursor": root.monokai_fusion.white,
                "accent": root.monokai_fusion.yellow5

            }
    })

    function getLuminance(hex) {
        let color = hex.replace('#', '')
        if (color.length === 3) {
            color = color[0] + color[0] + color[1] + color[1] + color[2] + color[2]
        }
        let r = parseInt(color.substr(0, 2), 16) / 255
        let g = parseInt(color.substr(2, 2), 16) / 255
        let b = parseInt(color.substr(4, 2), 16) / 255

        let a = [r, g, b].map(v => v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4))
        return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722
    }

    function getContrastRatio(hex1, hex2) {
        let l1 = getLuminance(hex1)
        let l2 = getLuminance(hex2)
        return (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05)
    }

    function getSaturation(hex) {
        let color = hex.replace('#', '');
        let r = parseInt(color.substr(0, 2), 16) / 255;
        let g = parseInt(color.substr(2, 2), 16) / 255;
        let b = parseInt(color.substr(4, 2), 16) / 255;
        let max = Math.max(r, g, b), min = Math.min(r, g, b);
        if (max === min) return 0;
        let l = (max + min) / 2;
        return l <= 0.5 ? (max - min) / (max + min) : (max - min) / (2 - max - min);
    }

    function calculateBestAccent(colorsObj, bgHex) {
        let bestColor = "";
        let bestScore = -1;

        for (let i = 1; i <= 6; i++) {
            let colorHex = colorsObj["color" + i];
            if (!colorHex || !bgHex) continue;

            let contrast = getContrastRatio(colorHex, bgHex);
            if (contrast < 2.0) continue;

            let saturation = getSaturation(colorHex);
            let score = (saturation * 0.7) + (Math.min(contrast / 10, 1.0) * 0.3);

            if (score > bestScore) {
                bestScore = score;
                bestColor = colorHex;
            }
        }

        if (!bestColor) {
            let maxSat = -1;
            for (let i = 1; i <= 6; i++) {
                let colorHex = colorsObj["color" + i];
                if (!colorHex) continue;
                let sat = getSaturation(colorHex);
                if (sat > maxSat) {
                    maxSat = sat;
                    bestColor = colorHex;
                }
            }
        }

        return bestColor || colorsObj.color4 || "#FFFFFF";
    }

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
        console.log('-------------------- Color Engine Log --------------------')
        console.log(`wallpaper brightness : ${root.wallpaperBrightness}`);
        console.log(`is wallpaper dark : ${root.isDark}`);
    }

    Connections {
        target: Pywal

        function onColorsChanged() {
            if (Pywal.colors && Pywal.colors.color1) {
                let currentBg = root.pywal.special.background;
                let newAccent = calculateBestAccent(Pywal.colors, currentBg);

                root.pywal = Object.assign({}, root.pywal, {
                        "colors": Pywal.colors,
                        "special": Object.assign({}, root.pywal.special, { "accent": newAccent })
                });
            }
        }

        function onSpecialChanged() {
            if (Pywal.special && Pywal.special.background) {
                let currentColors = root.pywal.colors;
                let newBg = Pywal.special.background;
                let newAccent = calculateBestAccent(currentColors, newBg);
                let mergedSpecial = Object.assign({}, Pywal.special, { "accent": newAccent });

                root.pywal = Object.assign({}, root.pywal, {
                        "special": mergedSpecial
                });
            }
        }

        function onWallpaperChanged() {
            root.analyzeWallpaper(Pywal.wallpaper);
        }
    }
}
