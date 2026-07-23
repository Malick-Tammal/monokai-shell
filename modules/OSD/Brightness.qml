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
        target:BrightnessService

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
            icon: BrightnessService.symbol
            surface: ColorEngine.monokai_fusion.purple9
            color: ColorEngine.monokai_fusion.purple5
            text: ColorEngine.monokai_fusion.purple9
            value: BrightnessService.brightness
            weight: 500
        }
    }
}
