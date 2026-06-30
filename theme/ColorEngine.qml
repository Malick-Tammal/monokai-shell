pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

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
                "cursor": root.monokai_fusion.white
            }
    })

    Connections {
        target: Pywal

        function onColorsChanged() {
            if (Pywal.colors && Pywal.colors.color1) {
                root.pywal = Object.assign({}, root.pywal, { "colors": Pywal.colors });
            }
        }

        function onSpecialChanged() {
            if (Pywal.special && Pywal.special.background) {
                root.pywal = Object.assign({}, root.pywal, { "special": Pywal.special });
            }
        }
    }
}
