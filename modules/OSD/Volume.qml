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

    property string mode: "volume"

    Connections {
        target: Audio

        function onInteractionTriggered() {
            root.mode = "volume";
            GlobalStates.volumeOsd = true;
            hideTimer.restart();
        }

        function onIsMicMutedChanged() {
            root.mode = "mic";
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
            root.mode = "volume";
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
            value: root.mode === "mic" ? Audio.micVolume : Audio.volume
            icon: root.mode === "mic" ? (Audio.isMicMuted ? "mic_off" : "mic") : Audio.symbol
            surface: Style.textOnSuccess
            accent: Style.success
            foreground: Style.textOnSuccess

            thumbColor: mode === "mic"
            ? (Audio.isMicMuted ? Style.successContainer : Style.success)
            : (Audio.isMuted ? Style.successContainer : Style.success)
        }
    }
}
