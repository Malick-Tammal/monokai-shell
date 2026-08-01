pragma Singleton
import QtQuick
import qs.core
import qs.services
import "./themes/"

QtObject {
    id: root

    //--------------------------------------------
    //  INFO: Helpers
    //--------------------------------------------

    readonly property bool _isMonokai: Configs.theme === "monokai_fusion"

    function withAlpha(baseColor, alpha): color {
        let c = Qt.color(baseColor);
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

    function palette(colorName, shade): color {
        if (_isMonokai) {
            return MonokaiFusion[colorName + shade] || MonokaiFusion.gray5;
        }

        let baseMap = {
            "yellow": root.warning,
            "red": root.error,
            "green": root.success,
            "purple": root.info,
            "blue": root.feature,
            "orange": root.notify,
            "gray": root.inactive
        };

        let base = baseMap[colorName] || root.inactive;

        if (shade <= 2) return Qt.lighter(base, 1.5);
        if (shade <= 4) return Qt.lighter(base, 1.15);
        if (shade === 5) return base;
        if (shade <= 7) return Qt.darker(base, 1.5);
        return Qt.darker(base, 3.5);
    }

    function _matugenColor(name): color {
        return Matugen.colors[name] || MonokaiFusion.gray5;
    }

    //--------------------------------------------
    //  INFO: Primary
    //--------------------------------------------

    readonly property color primary: _isMonokai ? MonokaiFusion.yellow5 : Style._matugenColor("primary")
    readonly property color textOnPrimary: _isMonokai ? MonokaiFusion.yellow9 : Style._matugenColor("colorOnPrimary")

    //--------------------------------------------
    //  INFO: Text Hierarchy
    //--------------------------------------------

    readonly property color textPrimary: _isMonokai ? MonokaiFusion.white : Style._matugenColor("colorOnSurface")
    readonly property color textSecondary: _isMonokai ? MonokaiFusion.gray1 : Style._matugenColor("colorOnSurfaceVariant")
    readonly property color textTertiary: _isMonokai ? MonokaiFusion.gray2 : Style._matugenColor("outline")
    readonly property color textMuted: _isMonokai ? MonokaiFusion.dark1 : Style._matugenColor("outlineVariant")
    readonly property color textDisabled: _isMonokai ? MonokaiFusion.gray3 : Style._matugenColor("outline")
    readonly property color textOnWallpaper: ColorEngine.textOnWallpaper
    readonly property color accentOnWallpaper: ColorEngine.accentOnWallpaper

    //--------------------------------------------
    //  INFO: Surfaces & Backgrounds
    //--------------------------------------------

    readonly property color background: _isMonokai ? MonokaiFusion.dark5 : Style._matugenColor("background")
    readonly property color surface: _isMonokai ? MonokaiFusion.dark4 : Style._matugenColor("surfaceContainerHigh")
    readonly property color surfaceAlt: _isMonokai ? MonokaiFusion.dark3 : Style._matugenColor("surfaceContainerHighest")
    readonly property color surfaceDim: _isMonokai ? MonokaiFusion.dark2 : Style._matugenColor("surfaceContainer")
    readonly property color overlay: _isMonokai ? MonokaiFusion.dark1 : Style._matugenColor("surfaceContainerLow")
    readonly property color trueBlack: _isMonokai ? MonokaiFusion.black : Style._matugenColor("shadow")

    //--------------------------------------------
    //  INFO: Borders & Dividers
    //--------------------------------------------

    readonly property color border: _isMonokai ? MonokaiFusion.yellow5 : Style._matugenColor("primary")
    readonly property color borderDim: _isMonokai ? MonokaiFusion.gray4 : Style._matugenColor("outlineVariant")
    readonly property color divider: _isMonokai ? MonokaiFusion.dark1 : Style._matugenColor("outlineVariant")

    //--------------------------------------------
    //  INFO: Status: Error (Red)
    //--------------------------------------------

    readonly property color error: _isMonokai ? MonokaiFusion.red5 : Style._matugenColor("error")
    readonly property color errorHover: _isMonokai ? MonokaiFusion.red4 : Qt.lighter(error, 1.15)
    readonly property color errorBorder: _isMonokai ? MonokaiFusion.red3 : Qt.lighter(error, 1.3)
    readonly property color errorContainer: _isMonokai ? MonokaiFusion.red8 : Style._matugenColor("errorContainer")
    readonly property color textOnError: _isMonokai ? MonokaiFusion.red9 : Style._matugenColor("colorOnError")

    //--------------------------------------------
    //  INFO: Status: Warning (Yellow)
    //--------------------------------------------

    readonly property color warning: _isMonokai ? MonokaiFusion.yellow5 : Style._matugenColor("primary")
    readonly property color warningHover: _isMonokai ? MonokaiFusion.yellow4 : Qt.lighter(warning, 1.15)
    readonly property color warningLight: _isMonokai ? MonokaiFusion.yellow2 : Qt.lighter(warning, 1.5)
    readonly property color warningBorder: _isMonokai ? MonokaiFusion.yellow3 : Qt.lighter(warning, 1.3)
    readonly property color warningContainer: _isMonokai ? MonokaiFusion.yellow8 : Qt.darker(warning, 2.5)
    readonly property color textOnWarning: _isMonokai ? MonokaiFusion.yellow9 : Qt.darker(warning, 3.5)

    //--------------------------------------------
    //  INFO: Status: Success (Green)
    //--------------------------------------------

    readonly property color success: _isMonokai ? MonokaiFusion.green5 : Qt.tint(Style._matugenColor("primary"), "#3000FF00")
    readonly property color successHover: _isMonokai ? MonokaiFusion.green4 : Qt.lighter(success, 1.15)
    readonly property color successMuted: _isMonokai ? MonokaiFusion.green7 : Qt.darker(success, 1.5)
    readonly property color successBorder: _isMonokai ? MonokaiFusion.green3 : Qt.lighter(success, 1.3)
    readonly property color successContainer: _isMonokai ? MonokaiFusion.green8 : Qt.darker(success, 2.5)
    readonly property color textOnSuccess: _isMonokai ? MonokaiFusion.green9 : Qt.darker(success, 3.5)

    //--------------------------------------------
    //  INFO: Module: Info (Purple)
    //--------------------------------------------

    readonly property color info: _isMonokai ? MonokaiFusion.purple5 : Style._matugenColor("tertiary")
    readonly property color infoHover: _isMonokai ? MonokaiFusion.purple4 : Qt.lighter(info, 1.15)
    readonly property color infoBorder: _isMonokai ? MonokaiFusion.purple2 : Qt.lighter(info, 1.5)
    readonly property color infoContainer: _isMonokai ? MonokaiFusion.purple9 : Style._matugenColor("tertiaryContainer")
    readonly property color textOnInfo: _isMonokai ? MonokaiFusion.purple9 : Style._matugenColor("colorOnTertiary")

    //--------------------------------------------
    //  INFO: Module: Feature (Blue)
    //--------------------------------------------

    readonly property color feature: _isMonokai ? MonokaiFusion.blue5 : Style._matugenColor("secondary")
    readonly property color featureHover: _isMonokai ? MonokaiFusion.blue4 : Qt.lighter(feature, 1.15)
    readonly property color featureBorder: _isMonokai ? MonokaiFusion.blue2 : Qt.lighter(feature, 1.5)
    readonly property color featureContainer: _isMonokai ? MonokaiFusion.blue9 : Style._matugenColor("secondaryContainer")
    readonly property color textOnFeature: _isMonokai ? MonokaiFusion.blue9 : Style._matugenColor("colorOnSecondary")

    //--------------------------------------------
    //  INFO: Module: Notify (Orange)
    //--------------------------------------------

    readonly property color notify: _isMonokai ? MonokaiFusion.orange5 : Qt.tint(Style._matugenColor("tertiary"), "#30FF8800")
    readonly property color notifyHover: _isMonokai ? MonokaiFusion.orange4 : Qt.lighter(notify, 1.15)
    readonly property color notifyBorder: _isMonokai ? MonokaiFusion.orange2 : Qt.lighter(notify, 1.5)
    readonly property color notifyContainer: _isMonokai ? MonokaiFusion.orange8 : Qt.darker(notify, 2.5)
    readonly property color textOnNotify: _isMonokai ? MonokaiFusion.orange9 : Qt.darker(notify, 3.5)

    //--------------------------------------------
    //  INFO: Interactive States
    //--------------------------------------------

    readonly property color inactive: _isMonokai ? MonokaiFusion.gray6 : Style._matugenColor("surfaceVariant")
    readonly property color inactiveText: _isMonokai ? MonokaiFusion.gray3 : Style._matugenColor("colorOnSurfaceVariant")
    readonly property color inactiveBorder: _isMonokai ? MonokaiFusion.dark1 : Style._matugenColor("outlineVariant")
    readonly property color indicatorIdle: _isMonokai ? MonokaiFusion.gray5 : Style._matugenColor("surfaceContainerHighest")

    //--------------------------------------------
    //  INFO: Typography
    //--------------------------------------------

    readonly property int fontSizeSm: 12
    readonly property int fontSizeMd: 14
    readonly property int fontSizeSub: 17
    readonly property int fontSizeLg: 18
    readonly property int fontSizeXl: 20
    readonly property int fontSize2Xl: 25

    readonly property string family: "SF Pro Rounded"
    readonly property string nerdFamily: "JetBrains Nerd Font"

    //--------------------------------------------
    //  INFO: Sizing & Spacing
    //--------------------------------------------

    readonly property int symbolSize: 15
    readonly property int symbolSizeXl: 18
    readonly property int symbolSize2Xl: 24

    readonly property int globalPadding: 10
}
