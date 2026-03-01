import QtQuick
import Quickshell
import qs.theme
import qs.services
import qs.components

Item {
    id: root

    height: parent.height
    width: childrenRect.width

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        height: parent.height
        width: row.width + 18
        radius: 10
        color: hoverHandler.hovered ? Style.purple4 : Style.purple5
        border.color: Style.purple3

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

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 5

            Symbols {
                icon: Network.symbol
                size: 14
                weight: 700
                iconColor: Style.purple9
            }

            Text {
                color: Style.purple9
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 80)

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeSm
                }

                text: {
                    if (Network.ethernet)
                        return Network.interfaceName || "Ethernet";

                    switch (Network.wifiStatus) {
                    case "connected":
                        return Network.networkName;
                    case "connecting":
                        return "Connecting...";
                    case "limited":
                        return "Limited Access";
                    case "disabled":
                        return "Disabled";
                    case "disconnected":
                        return "Disconnected";
                    default:
                        return "Unknown";
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CursorShape.PointingHandCursor
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    Quickshell.execDetached(["nmgui"]);
                } else if (mouse.button === Qt.RightButton) {
                    Network.toggleWifi();
                }
            }
        }
    }
}
