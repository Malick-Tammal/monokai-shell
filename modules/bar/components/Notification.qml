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
        color: mouseArea.containsMouse ? Style.notifyHover : Style.notify
        border.color: Style.notifyBorder

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
            spacing: 6

            Symbols {
                icon: NotifyService.notifCount > 0 ? "notifications_unread" : "notifications"
                size: Style.symbolSize
                color: Style.textOnNotify
                y: Math.round((parent.height - height) / 2)
            }

            Sliding {
                text: NotifyService.notifCount > 0 ? NotifyService.notifCount.toString() : ""
                visible: NotifyService.notifCount > 0 ? true : false
                size: Style.fontSizeMd
                textColor: Style.textOnNotify
                weight: Font.Bold
                styleName: "Bold"
                y: Math.round((parent.height - height) / 2)
            }
        }
    }
}
