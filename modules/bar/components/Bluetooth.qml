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
        width: row.implicitWidth + 18
        radius: 10
        clip: true

        color: {
            if (!Bluetooth.isAvailable)
                return Style.gray6;
            return hoverHandler.hovered ? Style.green4 : Style.green5;
        }
        border.color: Bluetooth.isAvailable ? Style.green3 : Style.dark1

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
            spacing: 4

            Symbols {
                id: btIcon
                icon: Bluetooth.symbol
                size: 14
                weight: 700
                iconColor: Bluetooth.isAvailable ? Style.green9 : Style.gray3

                SequentialAnimation on opacity {
                    id: pulseAnim
                    running: Bluetooth.isDiscovering && Bluetooth.isAvailable
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
                color: Bluetooth.isAvailable ? Style.green9 : Style.gray3
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering
                anchors.verticalCenterOffset: 0.5

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeSm
                }

                text: {
                    if (!Bluetooth.isAvailable)
                        return "Unavailable";
                    if (Bluetooth.isDiscovering)
                        return "Scanning...";
                    return Bluetooth.currentDeviceName;
                }

                elide: Text.ElideRight
                width: Math.min(implicitWidth, 150)
            }
        }
    }
}
