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

    readonly property QtObject _activeTheme: {
        if (Configs.theme === "monokai-fusion")
            return MonokaiFusion;
        return MonokaiFusion;
    }

    function palette(colorName, shade): color {
        if (!Configs.autoGenColors) {
            return _activeTheme[colorName + shade] || _activeTheme.gray5;
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

        if (shade <= 2)
            return Qt.lighter(base, 1.5);
        if (shade <= 4)
            return Qt.lighter(base, 1.15);
        if (shade === 5)
            return base;
        if (shade <= 7)
            return Qt.darker(base, 1.5);
        return Qt.darker(base, 3.5);
    }

    function _matugenColor(name): color {
        return Matugen.colors[name] || _activeTheme.gray5;
    }

    //--------------------------------------------
    //  INFO: Primary
    //--------------------------------------------

    readonly property color primary: Configs.autoGenColors ? Style._matugenColor("primary") : _activeTheme.yellow5
    readonly property color textOnPrimary: Configs.autoGenColors ? Style._matugenColor("colorOnPrimary") : _activeTheme.yellow9

    //--------------------------------------------
    //  INFO: Text Hierarchy
    //--------------------------------------------

    readonly property color textPrimary: Configs.autoGenColors ? Style._matugenColor("colorOnSurface") : _activeTheme.white
    readonly property color textSecondary: Configs.autoGenColors ? Style._matugenColor("colorOnSurfaceVariant") : _activeTheme.gray1
    readonly property color textTertiary: Configs.autoGenColors ? Style._matugenColor("outline") : _activeTheme.gray2
    readonly property color textMuted: Configs.autoGenColors ? Style._matugenColor("outlineVariant") : _activeTheme.dark1
    readonly property color textDisabled: Configs.autoGenColors ? Style._matugenColor("outline") : _activeTheme.gray3
    readonly property color textOnWallpaper: ColorEngine.textOnWallpaper
    readonly property color accentOnWallpaper: ColorEngine.accentOnWallpaper

    //--------------------------------------------
    //  INFO: Surfaces & Backgrounds
    //--------------------------------------------

    readonly property color background: Configs.autoGenColors ? Style._matugenColor("background") : _activeTheme.dark5
    readonly property color surface: Configs.autoGenColors ? Style._matugenColor("surfaceContainerHigh") : _activeTheme.dark4
    readonly property color surfaceAlt: Configs.autoGenColors ? Style._matugenColor("surfaceContainerHighest") : _activeTheme.dark3
    readonly property color surfaceDim: Configs.autoGenColors ? Style._matugenColor("surfaceContainer") : _activeTheme.dark2
    readonly property color overlay: Configs.autoGenColors ? Style._matugenColor("surfaceContainerLow") : _activeTheme.dark1
    readonly property color trueBlack: Configs.autoGenColors ? Style._matugenColor("shadow") : _activeTheme.black

    //--------------------------------------------
    //  INFO: Borders & Dividers
    //--------------------------------------------

    readonly property color border: Configs.autoGenColors ? Style._matugenColor("primary") : _activeTheme.yellow5
    readonly property color borderDim: Configs.autoGenColors ? Style._matugenColor("outlineVariant") : _activeTheme.gray4
    readonly property color divider: Configs.autoGenColors ? Style._matugenColor("outlineVariant") : _activeTheme.dark1

    //--------------------------------------------
    //  INFO: Status: Error (Red)
    //--------------------------------------------

    readonly property color error: Configs.autoGenColors ? Style._matugenColor("error") : _activeTheme.red5
    readonly property color errorHover: Configs.autoGenColors ? Qt.lighter(error, 1.15) : _activeTheme.red4
    readonly property color errorBorder: Configs.autoGenColors ? Qt.lighter(error, 1.3) : _activeTheme.red3
    readonly property color errorContainer: Configs.autoGenColors ? Style._matugenColor("errorContainer") : _activeTheme.red8
    readonly property color textOnError: Configs.autoGenColors ? Style._matugenColor("colorOnError") : _activeTheme.red9

    //--------------------------------------------
    //  INFO: Status: Warning (Yellow)
    //--------------------------------------------

    readonly property color warning: Configs.autoGenColors ? Style._matugenColor("primary") : _activeTheme.yellow5
    readonly property color warningHover: Configs.autoGenColors ? Qt.lighter(warning, 1.15) : _activeTheme.yellow4
    readonly property color warningLight: Configs.autoGenColors ? Qt.lighter(warning, 1.5) : _activeTheme.yellow2
    readonly property color warningBorder: Configs.autoGenColors ? Qt.lighter(warning, 1.3) : _activeTheme.yellow3
    readonly property color warningContainer: Configs.autoGenColors ? Qt.darker(warning, 2.5) : _activeTheme.yellow8
    readonly property color textOnWarning: Configs.autoGenColors ? Qt.darker(warning, 3.5) : _activeTheme.yellow9

    //--------------------------------------------
    //  INFO: Status: Success (Green)
    //--------------------------------------------

    readonly property color success: Configs.autoGenColors ? Qt.tint(Style._matugenColor("primary"), "#3000FF00") : _activeTheme.green5
    readonly property color successHover: Configs.autoGenColors ? Qt.lighter(success, 1.15) : _activeTheme.green4
    readonly property color successMuted: Configs.autoGenColors ? Qt.darker(success, 1.5) : _activeTheme.green7
    readonly property color successBorder: Configs.autoGenColors ? Qt.lighter(success, 1.3) : _activeTheme.green3
    readonly property color successContainer: Configs.autoGenColors ? Qt.darker(success, 2.5) : _activeTheme.green8
    readonly property color textOnSuccess: Configs.autoGenColors ? Qt.darker(success, 3.5) : _activeTheme.green9

    //--------------------------------------------
    //  INFO: Module: Info (Purple)
    //--------------------------------------------

    readonly property color info: Configs.autoGenColors ? Style._matugenColor("tertiary") : _activeTheme.purple5
    readonly property color infoHover: Configs.autoGenColors ? Qt.lighter(info, 1.15) : _activeTheme.purple4
    readonly property color infoBorder: Configs.autoGenColors ? Qt.lighter(info, 1.5) : _activeTheme.purple2
    readonly property color infoContainer: Configs.autoGenColors ? Style._matugenColor("tertiaryContainer") : _activeTheme.purple9
    readonly property color textOnInfo: Configs.autoGenColors ? Style._matugenColor("colorOnTertiary") : _activeTheme.purple9

    //--------------------------------------------
    //  INFO: Module: Feature (Blue)
    //--------------------------------------------

    readonly property color feature: Configs.autoGenColors ? Style._matugenColor("secondary") : _activeTheme.blue5
    readonly property color featureHover: Configs.autoGenColors ? Qt.lighter(feature, 1.15) : _activeTheme.blue4
    readonly property color featureBorder: Configs.autoGenColors ? Qt.lighter(feature, 1.5) : _activeTheme.blue2
    readonly property color featureContainer: Configs.autoGenColors ? Style._matugenColor("secondaryContainer") : _activeTheme.blue9
    readonly property color textOnFeature: Configs.autoGenColors ? Style._matugenColor("colorOnSecondary") : _activeTheme.blue9

    //--------------------------------------------
    //  INFO: Module: Notify (Orange)
    //--------------------------------------------

    readonly property color notify: Configs.autoGenColors ? Qt.tint(Style._matugenColor("tertiary"), "#30FF8800") : _activeTheme.orange5
    readonly property color notifyHover: Configs.autoGenColors ? Qt.lighter(notify, 1.15) : _activeTheme.orange4
    readonly property color notifyBorder: Configs.autoGenColors ? Qt.lighter(notify, 1.5) : _activeTheme.orange2
    readonly property color notifyContainer: Configs.autoGenColors ? Qt.darker(notify, 2.5) : _activeTheme.orange8
    readonly property color textOnNotify: Configs.autoGenColors ? Qt.darker(notify, 3.5) : _activeTheme.orange9

    //--------------------------------------------
    //  INFO: Interactive States
    //--------------------------------------------

    readonly property color inactive: Configs.autoGenColors ? Style._matugenColor("surfaceVariant") : _activeTheme.gray6
    readonly property color inactiveText: Configs.autoGenColors ? Style._matugenColor("colorOnSurfaceVariant") : _activeTheme.gray3
    readonly property color inactiveBorder: Configs.autoGenColors ? Style._matugenColor("outlineVariant") : _activeTheme.dark1
    readonly property color indicatorIdle: Configs.autoGenColors ? Style._matugenColor("surfaceContainerHighest") : _activeTheme.gray5

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
