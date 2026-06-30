import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "./components"
import qs.theme
import qs.services
import qs.core

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "powermenu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    exclusionMode: ExclusionMode.Ignore

    property string pendingCmd: ""
    property bool inConfirmation: false
    property Item lastActiveItem: null

    IpcHandler {
        target: "powermenu"
        function toggle(): void {
            GlobalStates.powerMenuVisible = !GlobalStates.powerMenuVisible;
        }
    }

    visible: GlobalStates.powerMenuVisible

    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            poweroff.forceActiveFocus();
        } else {
            inConfirmation = false;
            pendingCmd = "";
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.inConfirmation) {
                root.inConfirmation = false;
                if (root.lastActiveItem)
                root.lastActiveItem.forceActiveFocus();
            } else {
                GlobalStates.powerMenuVisible = false;
            }
        }
    }

    Shortcut {
        sequences: ["Escape", "Backspace", "q"]
        onActivated: GlobalStates.powerMenuVisible = false
    }

    Process {
        id: runner
    }

    function exec(cmd) {
        runner.command = ["bash", "-c", cmd];
        runner.running = true;
    }

    function requestExecute(cmd, sourceItem) {
        pendingCmd = cmd;
        lastActiveItem = sourceItem;
        inConfirmation = true;
    }

    Rectangle {
        width: main.width
        height: main.height

        color: "transparent"

        anchors {
            top: parent.top
            right: parent.right
            topMargin: BarService.isBarEffectivelyVisible ? BarService.barHeight + Style.globalPadding * 2 :Style.globalPadding

            rightMargin: Style.globalPadding

            Behavior on topMargin {
                SpringAnimation {
                    spring: 10
                    damping: 0.5
                    mass: 1.5
                }
            }
        }

        Rectangle {
            id: main

            width: col.implicitWidth + 20
            height: col.implicitHeight + 20

            border.color: Style.border
            border.width: 1
            antialiasing: true

            color: Style.bg
            radius: 15

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                id: col
                enabled: !root.inConfirmation

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
                    Layout.alignment: Qt.AlignBottom
                    Layout.fillWidth: true
                    spacing: 10

                    PowerBtn {
                        id: poweroff
                        prevItem: logout
                        nextItem: reboot
                        focus: true

                        activeColor: ColorEngine.monokai_fusion.red5
                        activeBorderColor: ColorEngine.monokai_fusion.red3
                        iconName: "power_settings_new"
                        iconColor: ColorEngine.monokai_fusion.gray2
                        activeIconColor: ColorEngine.monokai_fusion.red9

                        onActivated: requestExecute("systemctl poweroff", poweroff)
                    }

                    PowerBtn {
                        id: reboot
                        prevItem: poweroff
                        nextItem: sleep

                        activeColor: ColorEngine.monokai_fusion.green5
                        activeBorderColor: ColorEngine.monokai_fusion.green3
                        iconName: "replay"
                        iconColor: ColorEngine.monokai_fusion.gray2
                        activeIconColor: ColorEngine.monokai_fusion.green9

                        onActivated: requestExecute("systemctl reboot", reboot)
                    }

                    PowerBtn {
                        id: sleep
                        prevItem: reboot
                        nextItem: lock

                        activeColor: ColorEngine.monokai_fusion.yellow5
                        activeBorderColor: ColorEngine.monokai_fusion.yellow3
                        iconName: "bedtime"
                        iconColor: ColorEngine.monokai_fusion.gray2
                        activeIconColor: ColorEngine.monokai_fusion.yellow9

                        onActivated: requestExecute("systemctl suspend", sleep)
                    }

                    PowerBtn {
                        id: lock
                        prevItem: sleep
                        nextItem: logout

                        activeColor: ColorEngine.monokai_fusion.purple5
                        activeBorderColor: ColorEngine.monokai_fusion.purple3
                        iconName: "lock"
                        iconColor: ColorEngine.monokai_fusion.gray2
                        activeIconColor: ColorEngine.monokai_fusion.purple9

                        onActivated: {
                            GlobalStates.powerMenuVisible = false;
                            LockScreenService.locked = true;
                        }
                    }

                    PowerBtn {
                        id: logout
                        prevItem: lock
                        nextItem: poweroff
                        activeColor: ColorEngine.monokai_fusion.orange5
                        activeBorderColor: ColorEngine.monokai_fusion.orange3
                        iconName: "logout"
                        iconColor: ColorEngine.monokai_fusion.gray2
                        activeIconColor: ColorEngine.monokai_fusion.orange9
                        onActivated: requestExecute("hyprctl dispatch 'hl.dsp.exit()'", logout)
                    }
                }
            }

            Confirmation {
                id: confirmationPopup
                isActive: root.inConfirmation

                onConfirm: {
                    root.exec(root.pendingCmd);
                    root.inConfirmation = false;
                    GlobalStates.powerMenuVisible = false;
                }

                onCancel: {
                    root.inConfirmation = false;
                    if (root.lastActiveItem)
                    root.lastActiveItem.forceActiveFocus();
                }
            }
        }
    }
}
