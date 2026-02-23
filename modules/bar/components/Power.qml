import Quickshell
import QtQuick
import "../../../theme/"

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

        Image {
            source: "../../../assets/icons/power.svg"

            width: 13
            height: 13

            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)

            smooth: true
            antialiasing: true
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CursorShape.PointingHandCursor
            hoverEnabled: true
            onClicked: powerMenu.isVisible = !powerMenu.isVisible
        }
    }
}
