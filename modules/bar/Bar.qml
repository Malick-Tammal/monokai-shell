import Quickshell
import Quickshell.Wayland

import QtQuick
import "../../theme/"
import "./modules/"

PanelWindow {
    id: bar
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "bar"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        left: 10
        right: 10
        top: 10
    }

    implicitHeight: 42

    Row {
        id: row
        anchors.bottomMargin: 1
        anchors.topMargin: 1
        anchors.fill: parent

        Center {}
        Right {}
    }
}
