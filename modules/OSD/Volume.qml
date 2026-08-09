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

    implicitWidth: volumeLoader.implicitWidth + Style.globalPadding * 4
    implicitHeight: volumeLoader.implicitHeight
    color: "transparent"
    visible: GlobalStates.showVolumeOsd

    property string mode: "volume"

    Connections {
        target: Audio

        function onInteractionTriggered() {
            root.mode = "volume";
            GlobalStates.showVolumeOsd = true;
            hideTimer.restart();
        }

        function onIsMicMutedChanged() {
            root.mode = "mic";
            GlobalStates.showVolumeOsd = true;
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (volumeLoader.item?._dragging || volumeLoader.item?.hovered) {
                hideTimer.restart();
                return;
            }
            GlobalStates.showVolumeOsd = false;
            root.mode = "volume";
        }
    }

    Loader {
        id: volumeLoader
        active: GlobalStates.showVolumeOsd

        anchors {
            left: parent.left
            leftMargin: Style.globalPadding
        }

        sourceComponent: Slider {
            value: root.mode === "mic" ? Audio.micVolume : Audio.volume
            icon: root.mode === "mic" ? (Audio.isMicMuted ? "mic_off" : "mic") : Audio.materialSymbol
            surface: Style.textOnSuccess
            accent: Style.success
            foreground: Style.textOnSuccess
            thumbColor: root.mode === "mic" ? (Audio.isMicMuted ? Style.successContainer : Style.success) : (Audio.isMuted ? Style.successContainer : Style.success)
            allowEmpty: root.mode === "mic"

            onValueChangeRequested: v => {
                if (root.mode === "mic") {
                    if (Audio.source?.audio)
                        Audio.source.audio.volume = v;
                } else {
                    if (Audio.sink?.audio)
                        Audio.sink.audio.volume = Math.min(v, Audio.hardMaxValue);
                }
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
