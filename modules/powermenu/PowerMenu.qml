import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Io
import "./components"
import "../../theme/"

PanelWindow {
    id: window

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "powermenu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property bool isVisible: false

    IpcHandler {
        target: "powermenu"
        function toggle(): void {
            window.isVisible = !window.isVisible;
        }
    }

    visible: isVisible

    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    color: "transparent"

    MouseArea {
        anchors.fill: parent
        onClicked: window.isVisible = false
    }

    Shortcut {
        sequences: ["Escape", "Backspace", "q"]
        onActivated: window.isVisible = false
    }

    Process {
        id: runner
    }

    function exec(cmd) {
        runner.command = ["bash", "-c", cmd];
        runner.running = true;
    }

    Rectangle {
        width: 460
        height: 140

        color: "transparent"

        anchors {
            top: parent.top
            right: parent.right
            topMargin: 10
            rightMargin: 10
        }

        Rectangle {
            id: main

            anchors.fill: parent

            border.color: Style.border
            border.width: 1
            antialiasing: true

            color: Style.bg
            radius: 15

            ColumnLayout {
                id: col
                anchors.margins: 10
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    id: header
                    spacing: 10
                    Layout.fillWidth: true
                    anchors.top: parent.top

                    System {}
                    User {}
                }

                RowLayout {
                    id: powerButtons
                    Layout.fillWidth: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    PowerBtn {
                        id: poweroff
                        prevItem: logout
                        nextItem: reboot
                        focus: true

                        activeColor: Style.red
                        iconName: "poweroff"

                        onActivated: exec("systemctl poweroff")
                    }

                    PowerBtn {
                        id: reboot
                        prevItem: poweroff
                        nextItem: sleep

                        activeColor: Style.green
                        iconName: "reboot"

                        onActivated: exec("systemctl reboot")
                    }

                    PowerBtn {
                        id: sleep
                        prevItem: reboot
                        nextItem: lock

                        activeColor: Style.yellow
                        iconName: "sleep"

                        onActivated: exec("systemctl suspend")
                    }

                    PowerBtn {
                        id: lock
                        prevItem: sleep
                        nextItem: logout

                        activeColor: Style.purple
                        iconName: "lock"

                        onActivated: {
                            window.isVisible = false;
                            exec("hyprctl dispatch exec \"sh -c 'sleep 0.1; hyprlock'\"");
                        }
                    }

                    PowerBtn {
                        id: logout
                        prevItem: lock
                        nextItem: poweroff

                        activeColor: Style.orange
                        iconName: "logout"

                        onActivated: exec("hyprctl dispatch exit")
                    }
                }
            }
        }
    }
}
