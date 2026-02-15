import "../globals"
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import ".."

ListView {
    id: list
    clip: true
    spacing: 5
    // Use a Process to get networks if the native module fails,
    // but here we assume we are iterating a model passed from parent.
    model: networkModel

    delegate: Rectangle {
        width: list.width
        height: isExpanded ? 110 : 40
        color: isHovered ? "#1affffff" : "transparent"
        radius: 6
        clip: true

        property bool isExpanded: false
        property bool isHovered: false
        property string ssid: modelData.ssid || "Unknown"
        property bool secure: modelData.security !== ""

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuint
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.isHovered = true
            onExited: parent.isHovered = false
            onClicked: {
                // If it's a known network, just connect. If unknown/secure, expand.
                parent.isExpanded = !parent.isExpanded;
            }
        }

        // 1. The Header (Icon + Name)
        RowLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 12

            Text {
                text: "󰤨"
                color: Config.fg
                font.pixelSize: 16
            }
            Text {
                text: ssid
                color: Config.fg
                font {
                    family: Config.font
                    bold: true
                }
                Layout.fillWidth: true
            }
            Text {
                visible: secure
                text: ""
                color: Config.muted
            }
        }

        // 2. The Password Input (Hidden by default)
        ColumnLayout {
            visible: parent.isExpanded
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                height: 30
                color: "#202020"
                radius: 6
                border.color: "#404040"
                border.width: 1

                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: "white"
                    clip: true
                    echoMode: TextInput.Password
                    font.family: Config.font
                    text: ""

                    Text {
                        text: "Password..."
                        color: "#606060"
                        visible: parent.text === ""
                        anchors.left: parent.left
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Connect Button
                Rectangle {
                    Layout.fillWidth: true
                    height: 26
                    color: Config.accent
                    radius: 4
                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: "black"
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Run the reliable nmcli command
                            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", passInput.text];
                            connectProc.running = true;
                            parent.parent.parent.isExpanded = false;
                        }
                    }
                }
            }
        }
    }

    // The "Engine" that actually connects
    Process {
        id: connectProc
        command: []
        stdout: StdioCollector {
            onStreamFinished: console.log("Connection result: " + this.text)
        }
    }
}
