import "../globals"
import QtQuick
import Quickshell.Hyprland
import ".."

Row {
    spacing: 8
    Repeater {
        model: 5
        delegate: Rectangle {
            width: isFocused ? 24 : 8
            height: 8
            radius: 4

            // "?.id" checks if workspace exists.
            // "?? false" defaults to false if it's null.
            property bool isFocused: (Hyprland.focusedWorkspace?.id === index + 1) ?? false

            // Same safety for the 'hasWindows' check
            property bool hasWindows: Hyprland.workspaces.values.some(w => w.id === index + 1)

            color: isFocused ? Config.accent : (hasWindows ? Config.fg : Config.muted)

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
