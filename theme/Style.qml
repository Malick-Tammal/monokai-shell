pragma Singleton
import QtQuick

QtObject {
    id: root

    // Accents
    property color accent: ColorEngine.monokai_fusion.yellow5
    property color pywalAccent: ColorEngine.pywal.special.accent

    // Text
    property color textPrimary: ColorEngine.monokai_fusion.white
    property color textSecondary: ColorEngine.monokai_fusion.gray1
    property color textMuted: ColorEngine.monokai_fusion.dark1
    property color textTertiary: ColorEngine.monokai_fusion.gray2
    property color textDisabled: ColorEngine.monokai_fusion.gray3
    property color textOnWallpaper: ColorEngine.textOnWallpaper
    property color accentOnWallpaper: ColorEngine.accentOnWallpaper
    property color pywalForeground: ColorEngine.pywal.special.foreground

    // Surfaces
    property color background: ColorEngine.monokai_fusion.dark5
    property color surface: ColorEngine.monokai_fusion.dark4
    property color surfaceAlt: ColorEngine.monokai_fusion.dark3
    property color surfaceDim: ColorEngine.monokai_fusion.dark2
    property color overlay: ColorEngine.monokai_fusion.dark1
    property color pywalBackground: ColorEngine.pywal.special.background

    // Primary
    property color primary: ColorEngine.monokai_fusion.yellow5
    property color textOnPrimary: ColorEngine.monokai_fusion.yellow9

    // Borders and Dividers
    property color border: ColorEngine.monokai_fusion.yellow5
    property color borderDim: ColorEngine.monokai_fusion.gray4
    property color divider: ColorEngine.monokai_fusion.dark1

    // Status & Feedback
    property color error: ColorEngine.monokai_fusion.red5
    property color textOnError: ColorEngine.monokai_fusion.red9
    property color errorContainer: ColorEngine.monokai_fusion.red8
    property color textOnErrorContainer: ColorEngine.monokai_fusion.red5
    property color errorBorder: ColorEngine.monokai_fusion.red3

    property color warning: ColorEngine.monokai_fusion.yellow5
    property color textOnWarning: ColorEngine.monokai_fusion.yellow9
    property color warningContainer: ColorEngine.monokai_fusion.yellow8
    property color textOnWarningContainer: ColorEngine.monokai_fusion.yellow5
    property color warningBorder: ColorEngine.monokai_fusion.yellow3

    property color success: ColorEngine.monokai_fusion.green5
    property color textOnSuccess: ColorEngine.monokai_fusion.green9
    property color successContainer: ColorEngine.monokai_fusion.green8
    property color textOnSuccessContainer: ColorEngine.monokai_fusion.green5
    property color successBorder: ColorEngine.monokai_fusion.green3

    // Font Sizes
    property int fontSizeXXs: 8
    property int fontSizeXs: 10
    property int fontSizeSm: 12
    property int fontSizeMd: 14
    property int fontSizeSub: 17
    property int fontSizeLg: 18
    property int fontSizeXl: 20
    property int fontSize2Xl: 25
    property int fontSize3Xl: 30
    property int fontSize4Xl: 40

    // Font Families
    property string family: "SF Pro Rounded"
    property string nerdFamily: "JetBrains Nerd Font"

    // Symbol Sizes
    property int symbolSize: 15
    property int symbolSizeXl: 18
    property int symbolSize2Xl: 24

    // Padding
    property int globalPadding: 10
}
