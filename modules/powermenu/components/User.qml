import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.theme
import qs.components

Rectangle {
    id: user
    width: 200
    Layout.preferredHeight: 32
    color: ColorEngine.monokai_fusion.yellow5
    radius: 8

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
            color: ColorEngine.monokai_fusion.yellow5
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
                size: 19
                iconColor: ColorEngine.monokai_fusion.orange9
            }

            Text {
                text: "User"
                color: ColorEngine.monokai_fusion.orange9
                font {
                    family: Style.family
                    pixelSize: Style.fontSizeLg
                    weight: 600
                    styleName: "Semibold"
                }
            }
        }
    }
}
