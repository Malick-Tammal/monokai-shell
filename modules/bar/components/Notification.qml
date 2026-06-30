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
        color: mouseArea.containsMouse ? ColorEngine.monokai_fusion.orange4 : ColorEngine.monokai_fusion.orange5
        border.color: ColorEngine.monokai_fusion.orange2

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
                color: ColorEngine.monokai_fusion.orange9
                y: Math.round((parent.height - height) / 2)
            }

            Sliding {
                text: NotifyService.notifCount > 0 ? NotifyService.notifCount.toString() : ""
                visible: NotifyService.notifCount > 0 ? true : false
                size: Style.fontSizeMd
                textColor: ColorEngine.monokai_fusion.orange9
                weight: Font.Bold
                styleName: "Bold"
                y: Math.round((parent.height - height) / 2)
            }
        }
    }
}
