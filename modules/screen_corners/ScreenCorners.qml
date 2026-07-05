import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.components
import qs.theme

PanelWindow {
    id: root

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    exclusiveZone: 0
    WlrLayershell.namespace: "corners"

    mask: Region {}

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    Corners {
        anchors.fill: parent
    }
}
