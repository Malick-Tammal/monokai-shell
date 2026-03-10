import QtQuick
import Quickshell
import qs.theme
import qs.components
import qs.services

Item {
    id: root
    height: parent.height
    width: con.width

    Rectangle {
        id: con
        height: parent.height
        width: row.width + 20
        radius: 10
        color: mouseArea.containsMouse ? Style.orange4 : Style.orange5
        border.color: Style.orange3

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuart
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.CursorShape.PointingHandCursor
            hoverEnabled: true
            onClicked: Quickshell.execDetached(["swaync-client", "-t", "-sw"])
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 5

            Symbols {
                icon: NotifyService.notifCount > 0 ? "notifications_unread" : "notifications"
                size: 13
                color: Style.orange9
            }

            Sliding {
                text: NotifyService.notifCount > 0 ? NotifyService.notifCount.toString() : ""
                visible: NotifyService.notifCount > 0 ? true : false
                size: 12
                color: Style.orange9
                weight: Font.Bold
                anchors.bottom: parent.bottom
            }
        }
    }
}
