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
    WlrLayershell.namespace: "volume-osd"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        left: true
    }

    implicitWidth: volumeLoader.item ? volumeLoader.implicitWidth + Style.globalPadding * 4 : 0
    implicitHeight: volumeLoader.item ? volumeLoader.implicitHeight : 0
    color: "transparent"
    visible: GlobalStates.volumeOsd

    Connections {
        target: Audio

        function onInteractionTriggered() {
            GlobalStates.volumeOsd = true;
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        repeat: false
        onTriggered: {
            GlobalStates.volumeOsd = false;
        }
    }

    Loader {
        id: volumeLoader
        active: GlobalStates.volumeOsd

        anchors {
            left: parent.left
            leftMargin: Style.globalPadding
        }

        sourceComponent: Slider {
            icon: Audio.symbol
            surface: Style.textOnSuccess
            color: Style.success
            text: Style.textOnSuccess
            value: Audio.volume
        }
    }
}
