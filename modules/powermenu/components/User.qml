import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../theme/"

Rectangle {
    id: user
    width: 190
    Layout.preferredHeight: 30
    color: Style.yellow5
    radius: 8

    property string assetsPath: "../../../assets/"

    Rectangle {
        width: parent.width / 2 + 20
        height: parent.height - 2
        color: Style.bg
        radius: 8

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 1
        }

        Process {
            id: userNameProc
            command: ["whoami"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: userName.text = this.text
            }
        }

        Text {
            id: userName
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

            Text {
                text: ""
                font {
                    family: Style.nerdFamily
                    pixelSize: 14
                }
                renderType: Text.NativeRendering
            }

            Text {
                text: "User"
                color: Style.bg
                font {
                    family: Style.family
                    pixelSize: Style.fontSizeMd
                    weight: Font.DemiBold
                }
            }
        }
    }
}
