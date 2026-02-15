import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    width: column.width
    height: column.height

    Column {
        id: column
        spacing: 8

        Repeater {
            model: 10

            Rectangle {
                id: wsDot

                property int wsId: index + 1
                property bool isFocused: (Hyprland.focusedWorkspace?.id === index + 1) ?? false
                property bool hasWindows: Hyprland.workspaces.values.some(w => w.id === index + 1)

                visible: wsId <= 5 || hasWindows || isFocused

                width: visible ? 8 : 0
                height: visible ? (isFocused ? 35 : 8) : 0
                radius: visible ? 4 : 0

                color: isFocused ? "#FFD766" : (hasWindows ? "#FDFFF1" : "gray")

                Behavior on height {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }
    }
}
