import QtQuick
import Quickshell
import Quickshell.Wayland
import "./components/indicators/"
import qs.theme
import qs.core
import qs.services

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "osd"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        left: true
    }

    implicitWidth: osdLoader.item ? osdLoader.implicitWidth + Style.globalPadding * 4 : 0
    implicitHeight: osdLoader.item ? osdLoader.implicitHeight : 0
    color: "transparent"

    visible: GlobalStates.osd

    Component {
        id: volumeComponent
        Volume {
            anchors.leftMargin: Style.globalPadding
        }
    }

    Component {
        id: brightnessComponent
        Brightness {
            anchors.leftMargin: Style.globalPadding
        }
    }

    function showOsd(component) {
        osdLoader.sourceComponent = component;
        GlobalStates.osd = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1000
        repeat: false
        onTriggered: {
            GlobalStates.osd = false;
        }
    }

    Connections {
        target: Audio

        function onInteractionTriggered() {
            root.showOsd(volumeComponent);

            root.anchors.right = false
            root.anchors.left = true
        }
    }

    Connections {
        target: BrightnessService

        function onInteractionTriggered() {
            root.showOsd(brightnessComponent);

            root.anchors.right = true
            root.anchors.left = false
        }
    }

    Loader {
        id: osdLoader
        active: GlobalStates.osd
        anchors.centerIn: parent
    }
}
