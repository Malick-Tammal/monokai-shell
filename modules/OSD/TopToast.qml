import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.theme
import qs.services
import "./components/"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "top-toast"
    exclusionMode: ExclusionMode.Ignore

    property string _mode: ""

    readonly property var toastData: {
        switch (root._mode) {
        case "keyboard":
            return {
                icon: "language_chinese_array",
                text: KbService.shortLayout,
                accent: Style.primary,
                surface: Style.textOnPrimary,
                lightSurface: Style.warningLight
            };
        case "ac":
            return {
                icon: "electrical_services",
                text: Battery.isPluggedIn ? "Connected" : "Disconnected",
                accent: Style.error,
                surface: Style.textOnError,
                lightSurface: Style.errorBorder
            };
        case "game":
            return {
                icon: "gamepad",
                text: GameMode.enabled ? "ON" : "OFF",
                accent: Style.info,
                surface: Style.textOnInfo,
                lightSurface: Style.infoBorder
            };
        default:
            return {
                icon: "",
                text: "",
                accent: "transparent",
                surface: "transparent",
                lightSurface: "transparent"
            };
        }
    }

    anchors {
        top: true
    }

    color: "transparent"

    implicitWidth: toastLoader.implicitWidth
    implicitHeight: toastLoader.implicitHeight + (Style.globalPadding * 2 + BarService.barHeight) + 100
    visible: GlobalStates.showToast

    Connections {
        target: KbService

        function onCurrentLayoutChanged() {
            root._mode = "keyboard";
            GlobalStates.showToast = true;
            hideTimer.restart();
        }
    }

    Connections {
        target: Battery

        function onIsPluggedInChanged() {
            root._mode = "ac";
            GlobalStates.showToast = true;
            hideTimer.restart();
        }
    }

    Connections {
        target: GameMode

        function onEnabledChanged() {
            root._mode = "game";
            GlobalStates.showToast = true;
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        repeat: false
        onTriggered: {
            GlobalStates.showToast = false;
        }
    }

    Loader {
        id: toastLoader
        active: GlobalStates.showToast

        anchors {
            top: parent.top
            topMargin: (GlobalStates.isBarHovered || GlobalStates.barVisible) ? BarService.barHeight + Style.globalPadding * 2 : Style.globalPadding

            Behavior on topMargin {
                SpringAnimation {
                    spring: 10
                    damping: 0.5
                    mass: 1.5
                }
            }
        }

        sourceComponent: Toast {
            text: root.toastData.text
            icon: root.toastData.icon
            accentColor: root.toastData.accent
            surfaceColor: root.toastData.surface
            lightSurfaceColor: root.toastData.lightSurface
        }
    }
}
