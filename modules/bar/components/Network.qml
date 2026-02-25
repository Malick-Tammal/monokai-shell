import QtQuick
import Quickshell

import "../../../theme/"
import "../../../components/"
import qs.services as Services

Item {
    id: networkWidget

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

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 5

            Symbols {
                icon: Services.Network.symbol
                size: 14
                weight: 700
                iconColor: Style.purple9
            }

            Text {
                color: Style.purple9
                anchors.verticalCenter: parent.verticalCenter

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeSm
                }

                text: {
                    if (Services.Network.ethernet)
                        return Services.Network.interfaceName || "Ethernet";

                    switch (Services.Network.wifiStatus) {
                    case "connected":
                        return Services.Network.networkName;
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
                    Services.Network.toggleWifi();
                }
            }
        }
    }
}
