pragma Singleton
import QtQuick

QtObject {
    property color bg: ColorEngine.monokai_fusion.dark5
    property color fg: ColorEngine.monokai_fusion.white
    property color border: ColorEngine.monokai_fusion.yellow5

    // Accents
    property color accent: ColorEngine.monokai_fusion.yellow5
    property color pywalAccent: ColorEngine.pywal.special.accent

    // Text hierarchy
    property color textPrimary: ColorEngine.monokai_fusion.white
    property color textSecondary: ColorEngine.monokai_fusion.gray2
    property color textMuted: ColorEngine.monokai_fusion.gray4
    property color textOnWallpaper: ColorEngine.textOnWallpaper
    property color accentOnWallpaper: ColorEngine.accentOnWallpaper

    // Surfaces
    property color surface: ColorEngine.monokai_fusion.dark5
    property color surfaceAlt: ColorEngine.monokai_fusion.dark4
    property color surfaceDim: ColorEngine.monokai_fusion.dark2
    property color overlay: ColorEngine.monokai_fusion.dark1

    property int fontSizeXXs: 8
    property int fontSizeXs: 10
    property int fontSizeSm: 12
    property int fontSizeMd: 14
    property int fontSizeLg: 18
    property int fontSizeXl: 20
    property int fontSize2Xl: 25
    property int fontSize3Xl: 30
    property int fontSize4Xl: 40

    property string family: "SF Pro Rounded"
    property string nerdFamily: "JetBrains Nerd Font"

    property int symbolSize: 15
    property int globalPadding: 10
}
