import QtQuick
import qs.theme
import "../../../components/"
import Qt5Compat.GraphicalEffects
import Quickshell.Services.UPower

Item {
    id: batteryWidget
    height: parent.height
    width: con.width

    property int percentage: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 0
    property bool isCharging: UPower.displayDevice ? (UPower.displayDevice.state !== UPowerDeviceState.Discharging) : false

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        id: con
        height: parent.height
        width: row.width + 18
        radius: 10
        color: batteryWidget.isCharging ? Style.green2 : Style.orange2
        clip: true

        Item {
            id: fillSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: batteryPer
                height: parent.height
                width: parent.width * (batteryWidget.percentage / 100)
                color: batteryWidget.isCharging ? (hoverHandler.hovered ? Style.green4 : Style.green5) : (hoverHandler.hovered ? Style.orange4 : Style.orange5)

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
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
            border.color: batteryWidget.isCharging ? Style.green2 : Style.orange2
            border.width: 1
            radius: con.radius
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 5

            Symbols {
                icon: "battery_android_full"
                size: 14
                iconColor: Style.orange9
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

            Icons {
                path: "../../../assets/icons/zap.svg"
                size: 13
                visible: isCharging
                anchors.verticalCenter: parent.verticalCenter

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
                text: batteryWidget.percentage
                anchors.verticalCenter: parent.verticalCenter
                color: batteryWidget.isCharging ? Style.green9 : Style.orange9
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
            hoverEnabled: true
        }
    }
}
