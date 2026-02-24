import Quickshell
import QtQuick
import "../../../theme/"
import Qt5Compat.GraphicalEffects
import Quickshell.Services.UPower
import QtQuick.Shapes

Item {
    id: battery
    height: parent.height
    width: parent.height * 1.7

    property int percentage: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 0
    property bool isCharging: UPower.displayDevice ? (UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged) : false

    property string normalIcon: "../../../assets/icons/normal/battery.svg"
    property string chargingIcon: "../../../assets/icons/normal/zap.svg"

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        id: con
        anchors.fill: parent
        radius: 10
        color: battery.isCharging ? Style.green2 : Style.orange2

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
            spacing: 3

            Item {
                width: 16
                height: 16

                // 1. The Charging Icon
                Image {
                    // anchors.fill: parent
                    source: battery.chargingIcon

                    sourceSize.width: 14
                    sourceSize.height: 14

                    visible: isCharging

                    smooth: true
                    antialiasing: true
                }

                // 2. The Normal Battery Icon
                Image {
                    anchors.fill: parent
                    source: battery.normalIcon

                    sourceSize.width: 16
                    sourceSize.height: 16

                    visible: !isCharging

                    smooth: true
                    antialiasing: true
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
