import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../theme/"
import "../../components/"
import "./components/"

PanelWindow {
    id: window
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "bar"

    property color border: Style.dark4
    property string orientation: "vertical"

    implicitWidth: window.orientation === "vertical" ? 55 : 0
    implicitHeight: window.orientation === "vertical" ? 0 : 50

    anchors {
        top: true
        bottom: window.orientation === "vertical" ? true : false
        left: true
        right: window.orientation === "vertical" ? false : true
    }

    margins {
        right: window.orientation === "vertical" ? -20 : 0
        bottom: window.orientation === "vertical" ? 0 : -20
    }

    Rectangle {
        id: bar
        height: window.orientation === "vertical" ? parent.height : 30
        width: window.orientation === "vertical" ? 35 : parent.width
        color: Style.bg
        visible: true
        z: 99

        Cornor {
            position: window.orientation === "vertical" ? "top" : "left"
            target: bar
            haveBorder: true
            borderColor: window.border
        }

        Cornor {
            position: window.orientation === "vertical" ? "bottom" : "right"
            target: bar
            haveBorder: true
            borderColor: window.border
        }

        Rectangle {
            id: border

            anchors {
                right: window.orientation === "vertical" ? parent.right : ""
                top: window.orientation === "vertical" ? parent.top : ""
                bottom: parent.bottom

                margins: {
                    right: 0;
                }
            }

            width: window.orientation === "vertical" ? 1 : parent.width
            height: window.orientation === "vertical" ? parent.height : 1
            color: window.border
            z: 0
        }
    }
}
