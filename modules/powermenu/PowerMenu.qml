import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Io
import "./components"
import qs.theme

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
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 10

                RowLayout {
                    id: header
                    spacing: 10
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    System {}
                    User {}
                }

                RowLayout {
                    id: powerButtons
                    Layout.alignment: Qt.AlignCenter
                    spacing: 10

                    PowerBtn {
                        id: poweroff
                        prevItem: logout
                        nextItem: reboot
                        focus: true

                        activeColor: Style.red5
                        activeBorderColor: Style.red3
                        iconName: "power_settings_new"
                        iconColor: Style.gray2
                        activeIconColor: Style.red9

                        onActivated: exec("systemctl poweroff")
                    }

                    PowerBtn {
                        id: reboot
                        prevItem: poweroff
                        nextItem: sleep

                        activeColor: Style.green5
                        activeBorderColor: Style.green3
                        iconName: "replay"
                        iconColor: Style.gray2
                        activeIconColor: Style.green9

                        onActivated: exec("systemctl reboot")
                    }

                    PowerBtn {
                        id: sleep
                        prevItem: reboot
                        nextItem: lock

                        activeColor: Style.yellow5
                        activeBorderColor: Style.yellow3
                        iconName: "bedtime"
                        iconColor: Style.gray2
                        activeIconColor: Style.yellow9

                        onActivated: exec("systemctl suspend")
                    }

                    PowerBtn {
                        id: lock
                        prevItem: sleep
                        nextItem: logout

                        activeColor: Style.purple5
                        activeBorderColor: Style.purple3
                        iconName: "lock"
                        iconColor: Style.gray2
                        activeIconColor: Style.purple9

                        onActivated: {
                            window.isVisible = false;
                            exec("hyprctl dispatch exec \"sh -c 'sleep 0.1; hyprlock'\"");
                        }
                    }

                    PowerBtn {
                        id: logout
                        prevItem: lock
                        nextItem: poweroff

                        activeColor: Style.orange5
                        activeBorderColor: Style.orange3
                        iconName: "logout"
                        iconColor: Style.gray2
                        activeIconColor: Style.orange9

                        onActivated: exec("hyprctl dispatch exit")
                    }
                }
            }
        }
    }
}
