import QtQuick
import "../../../theme/"
import "../../../components/"
import Qt5Compat.GraphicalEffects
import Quickshell.Services.UPower

Item {
    id: battery
    height: parent.height
    width: parent.height * 1.7

    property int percentage: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 0
    property bool isCharging: UPower.displayDevice ? (UPower.displayDevice.state !== UPowerDeviceState.Discharging) : false

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        id: con
        anchors.fill: parent
        radius: 10
        color: battery.isCharging ? Style.green2 : Style.orange2
        clip: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CursorShape.PointingHandCursor
            hoverEnabled: true
            onClicked: powerMenu.isVisible = !powerMenu.isVisible
        }

        Item {
            id: fillSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: batteryPer
                height: parent.height
                width: parent.width * (battery.percentage / 100)
                color: battery.isCharging ? Style.green5 : (hoverHandler.hovered ? Style.orange4 : Style.orange5)
            }
        }

        OpacityMask {
            anchors.fill: con
            source: fillSource
            maskSource: Rectangle {
                width: con.width
                height: con.height
                radius: con.radius
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: battery.isCharging ? Style.green2 : Style.orange2
            border.width: 1
            radius: con.radius
        }

        Row {
            anchors.centerIn: parent
            spacing: 5

            Symbols {
                icon: "battery_android_full"
                size: 15
                iconColor: Style.green9
                visible: !isCharging

                transform: Translate {
                    x: !isCharging ? 0 : -parent.width

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Symbols {
                icon: "bolt"
                size: 13
                iconColor: Style.green9
                visible: isCharging

                transform: Translate {
                    x: isCharging ? 0 : -parent.width

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Text {
                text: battery.percentage
                anchors.verticalCenter: parent.verticalCenter
                color: battery.isCharging ? Style.green9 : Style.orange9
                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeSm
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CursorShape.PointingHandCursor
            onClicked: print(battery.isCharging)
        }
    }
}
