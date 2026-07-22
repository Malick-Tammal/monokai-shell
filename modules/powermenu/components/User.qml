import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.theme
import qs.components

Rectangle {
    id: user
    width: 200
    Layout.preferredHeight: 32
    color: Style.warning
    radius: 8

    Rectangle {
        width: parent.width / 2 + 20
        height: parent.height - 2
        color: Style.background
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
            color: Style.warning
            font {
                family: Style.family
                pixelSize: Style.fontSizeMd
                weight: 600
                styleName: "Semibold"
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

            Symbols {
                icon: "person"
                size: 18
                color: Style.textOnWarning
            }

            Text {
                text: "User"
                color: Style.textOnWarning

                font {
                    family: Style.family
                    pixelSize: Style.fontSizeSub
                    weight: 600
                    styleName: "Semibold"
                }
            }
        }
    }
}
