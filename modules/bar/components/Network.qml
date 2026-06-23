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
        width: row.implicitWidth + 20
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
            spacing: 6

            Symbols {
                icon: Network.symbol
                size: Style.symbolSize
                weight: Font.Bold
                iconColor: Style.purple9
            }

            Text {
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
                        return "Off";
                        case "disconnected":
                        return "Disconnected";
                        default:
                        return "Unknown";
                    }
                }

                color: Style.purple9
                renderType: Text.NativeRendering
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 80)

                y: Math.round((parent.height - height) / 2)

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeMd
                    styleName: "Bold"
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
