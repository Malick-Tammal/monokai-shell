import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/"
import "../../theme/"

PanelWindow {
    id: main

    property int rounding: 20
    property color cornors: Style.black

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    mask: Region {}

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"

    Rectangle {
        anchors.fill: parent

        color: "transparent"

        Inverted {
            anchors.right: parent.right
            anchors.top: parent.top
            rounding: main.rounding
            z: 2
            roundingColor: main.cornors
        }

        Inverted {
            anchors.left: parent.left
            anchors.top: parent.top
            rounding: main.rounding
            z: 2
            rotation: -90
            roundingColor: main.cornors
        }

        Inverted {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            rounding: main.rounding
            z: 2
            rotation: 90
            roundingColor: main.cornors
        }

        Inverted {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            rounding: main.rounding
            z: 2
            rotation: -180
            roundingColor: main.cornors
        }
    }
}
