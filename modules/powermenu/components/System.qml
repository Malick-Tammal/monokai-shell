import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "../../../theme/"

Rectangle {
    id: system
    Layout.fillWidth: true
    Layout.preferredHeight: 30
    color: Style.yellow5
    radius: 8

    property string assetsPath: "../../../assets/"

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

        Process {
            id: upTimeProc
            command: ["uptime", "-p"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: {
                    let clean = this.text.trim();

                    let h = 0;
                    let m = 0;

                    let matchH = clean.match(/(\d+)\s+hours?/);
                    if (matchH)
                        h = matchH[1];

                    let matchM = clean.match(/(\d+)\s+minutes?/);
                    if (matchM)
                        m = matchM[1];

                    upTime.text = `${h} Hours , ${m} Mins`;
                }
            }
        }

        Text {
            id: upTime
            text: "6 Hours , 23 Mins"
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

            Item {
                width: 18
                height: 18

                Image {
                    source: `${system.assetsPath}/icons/arch.svg`
                    anchors.fill: parent
                    sourceSize.width: 18
                    sourceSize.height: 18
                    smooth: false
                    antialiasing: false
                }
            }

            Text {
                text: "System"
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
