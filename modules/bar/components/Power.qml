import Quickshell
import QtQuick
import qs.theme
import "../../../components/"

Item {
    id: powerBtn
    height: parent.height
    width: parent.height

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: hoverHandler.hovered ? Style.red4 : Style.red5
        border.color: Style.red3

        Icons {
            path: "../../../assets/icons/power.svg"
            size: 14

            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CursorShape.PointingHandCursor
            hoverEnabled: true
            onClicked: powerMenu.isVisible = !powerMenu.isVisible
        }
    }
}
