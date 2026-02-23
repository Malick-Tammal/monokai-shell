import Quickshell
import QtQuick
import "../../../theme/"
import Qt5Compat.GraphicalEffects
import Quickshell.Services.UPower

Item {
    id: battery
    height: parent.height
    width: parent.height * 1.7

    property int percentage: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 0
    property bool isCharging: UPower.displayDevice ? (UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged) : false

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        id: con
        anchors.fill: parent
        radius: 10
        color: Style.orange2

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
            border.color: battery.isCharging ? Style.green3 : Style.orange2
            border.width: 1
            radius: con.radius
        }

        Text {
            text: battery.percentage
            anchors.centerIn: parent
            color: Style.orange9
            font {
                family: Style.family
                weight: Font.Bold
                pixelSize: Style.fontSizeSm
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CursorShape.PointingHandCursor
            onClicked: print(battery.isCharging)
        }
    }
}
