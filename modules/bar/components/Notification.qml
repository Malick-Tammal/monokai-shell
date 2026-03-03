import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme
import qs.components

Item {
    id: root
    height: parent.height
    width: con.width

    property int notifCount: 0

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
                icon: root.notifCount > 0 ? "notifications_unread" : "notifications"
                size: 13
                color: Style.orange9
            }

            Sliding {
                text: root.notifCount > 0 ? root.notifCount.toString() : ""
                visible: root.notifCount > 0 ? true : false
                size: 12
                color: Style.orange9
                weight: Font.Bold
            }
        }
    }

    Process {
        id: swayncListener
        running: true
        command: ["swaync-client", "--subscribe-waybar"]

        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "")
                    return;

                try {
                    let json = JSON.parse(data);

                    root.notifCount = parseInt(json.text, 10) || 0;
                } catch (e) {
                    console.error("Failed to parse swaync output:", e, "Raw data:", data);
                }
            }
        }
    }
}
