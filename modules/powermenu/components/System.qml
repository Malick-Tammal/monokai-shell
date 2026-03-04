import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.components

Rectangle {
    id: system
    Layout.fillWidth: true
    Layout.preferredHeight: 30
    color: Style.yellow5
    radius: 8

    Rectangle {
        width: parent.width / 2 + 20
        height: parent.height - 2
        color: Style.bg
        radius: 7

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 1
        }

        Text {
            id: upTime
            text: DateTime.upTime
            color: Style.yellow5
            font {
                family: Style.family
                pixelSize: Style.fontSizeSm
                weight: Font.DemiBold
            }
            anchors.centerIn: parent
        }
    }

    Rectangle {
        width: parent.width / 2 - 20
        height: parent.height - 2
        color: "transparent"

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 1
        }

        RowLayout {
            spacing: 5
            anchors.centerIn: parent

            Nerd {
                icon: "󰣇"
                size: 18
                color: Style.orange9
            }

            Text {
                text: "System"
                color: Style.orange9
                font {
                    family: Style.family
                    pixelSize: Style.fontSizeMd
                    weight: Font.DemiBold
                }
            }
        }
    }
}
