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
        color: hoverHandler.hovered ? ColorEngine.monokai_fusion.purple4 : ColorEngine.monokai_fusion.purple5
        border.color: ColorEngine.monokai_fusion.purple2

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
                icon: Network.materialSymbol
                size: Style.symbolSize
                weight: Font.Bold
                color: ColorEngine.monokai_fusion.purple9
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

                color: ColorEngine.monokai_fusion.purple9
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
