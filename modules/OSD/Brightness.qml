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

    implicitWidth: brightnessLoader.item ? brightnessLoader.implicitWidth + Style.globalPadding * 4 : 0
    implicitHeight: brightnessLoader.item ? brightnessLoader.implicitHeight : 0
    color: "transparent"
    visible: GlobalStates.brightnessOsd

    Connections {
        target: BrightnessService

        function onInteractionTriggered() {
            GlobalStates.brightnessOsd = true;
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
            GlobalStates.brightnessOsd = false;
        }
    }

    Loader {
        id: brightnessLoader
        active: GlobalStates.brightnessOsd

        anchors {
            right: parent.right
            rightMargin: Style.globalPadding
        }

        sourceComponent: Slider {
            value: BrightnessService.brightness
            icon: BrightnessService.symbol
            surface: ColorEngine.monokai_fusion.purple9
            accent: ColorEngine.monokai_fusion.purple5
            foreground: ColorEngine.monokai_fusion.purple9
            thumbColor: ColorEngine.monokai_fusion.purple5

            onValueChangeRequested: (v) => {
                BrightnessService.setBrightness(v)
            }

            on_DraggingChanged: {
                if (_dragging)
                    hideTimer.stop()
                else
                    hideTimer.restart()
            }
        }
    }
}
