import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.services
import qs.theme
import "./components/"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "brightness-osd"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        right: true
    }

    implicitWidth: brightnessLoader.implicitWidth + Style.globalPadding * 4
    implicitHeight: brightnessLoader.implicitHeight
    color: "transparent"
    visible: GlobalStates.showBrightnessOsd

    onVisibleChanged: {
        if (visible && !hideTimer.running)
            hideTimer.restart();
    }

    Connections {
        target: BrightnessService

        function onInteractionTriggered() {
            GlobalStates.showBrightnessOsd = true;
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (brightnessLoader.item?._dragging || brightnessLoader.item?.hovered) {
                hideTimer.restart();
                return;
            }
            GlobalStates.showBrightnessOsd = false;
        }
    }

    Loader {
        id: brightnessLoader
        active: GlobalStates.showBrightnessOsd

        anchors {
            right: parent.right
            rightMargin: Style.globalPadding
        }

        sourceComponent: Slider {
            value: BrightnessService.brightness
            icon: BrightnessService.symbol
            surface: Style.textOnInfo
            accent: Style.info
            foreground: Style.textOnInfo
            thumbColor: Style.info

            onValueChangeRequested: v => {
                BrightnessService.setBrightness(v);
            }

            on_DraggingChanged: {
                if (_dragging)
                    hideTimer.stop();
                else
                    hideTimer.restart();
            }
        }
    }
}
