import QtQuick
import Quickshell
import qs.theme
import qs.components
import qs.services

Item {
    id: root

    height: parent.height
    width: backgroundRect.width

    HoverHandler {
        id: hoverHandler
        enabled: Bluetooth.isAvailable
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Bluetooth.isAvailable ? Qt.CursorShape.PointingHandCursor : Qt.CursorShape.ForbiddenCursor
        hoverEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (!Bluetooth.isAvailable)
            return;

            if (mouse.button === Qt.RightButton) {
                Bluetooth.toggleBluetooth();
                return;
            }

            if (mouse.button === Qt.LeftButton) {
                // Bluetooth.toggleDiscovery();
                Quickshell.execDetached(["blueman-manager"]);
                return;
            }
        }
    }

    Rectangle {
        id: backgroundRect
        height: parent.height
        width: row.implicitWidth + 20
        radius: 10
        clip: true

        color: {
            if (!Bluetooth.isAvailable)
            return ColorEngine.monokai_fusion.gray6;
            return hoverHandler.hovered ? ColorEngine.monokai_fusion.green4 : ColorEngine.monokai_fusion.green5;
        }
        border.color: Bluetooth.isAvailable ? ColorEngine.monokai_fusion.green2 : ColorEngine.monokai_fusion.dark1

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
            height: parent.height
            spacing: 6

            Symbols {
                id: btIcon
                icon: Bluetooth.symbol
                size: Style.symbolSize
                weight: Font.Bold
                color: Bluetooth.isAvailable ? ColorEngine.monokai_fusion.green9 : ColorEngine.monokai_fusion.gray3

                y: Math.round((parent.height - height) / 2)

                SequentialAnimation on opacity {
                    id: pulseAnim
                    running: Bluetooth.isDiscovering && Bluetooth.isAvailable && Bluetooth.isManualScan
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.3
                        duration: 600
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: 1.0
                        duration: 600
                        easing.type: Easing.InOutSine
                    }

                    onRunningChanged: {
                        if (!running) {
                            btIcon.opacity = 1.0;
                        }
                    }
                }
            }

            Text {
                text: {
                    if (!Bluetooth.isAvailable)
                    return "Unavailable";
                    if (Bluetooth.isDiscovering && Bluetooth.isManualScan)
                    return "Scanning...";
                    return Bluetooth.currentDeviceName;
                }

                color: Bluetooth.isAvailable ? ColorEngine.monokai_fusion.green9 : ColorEngine.monokai_fusion.gray3
                renderType: Text.NativeRendering
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 150)

                y: Math.round((parent.height - height) / 2)

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeMd
                    styleName: "Bold"
                }
            }
        }
    }
}
