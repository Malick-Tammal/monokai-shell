import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import "../../theme/"

PanelWindow {
    id: window
    implicitWidth: dockWidth
    implicitHeight: dockHeight + 10
    color: "transparent"

    anchors {
        bottom: true
    }

    property var windowList: []
    property int dockWidth: 800
    property int dockHeight: 60
    property alias animY: dockTranslate.y

    // INTELLIHIDE
    readonly property bool overlapsWindow: {
        if (windowList.length === 0)
            return false;

        const dockTopEdge = (window.screen.y + window.screen.height) - dockHeight;
        const currentWsId = Hyprland.focusedWorkspace?.id ?? -999;

        return windowList.some(win => {
            if (win.workspace.id !== currentWsId)
                return false;

            if (win.at[0] === -32000)
                return false;

            const winBottomEdge = win.at[1] + win.size[1];
            return winBottomEdge > dockTopEdge;
        });
    }

    readonly property bool isHovered: dockMouseArea.containsMouse || activatorMouseArea.containsMouse
    readonly property bool shouldHide: overlapsWindow && !isHovered

    WlrLayershell.exclusiveZone: -1

    Process {
        id: getClients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    window.windowList = JSON.parse(text);
                } catch (e) {
                    console.error("Failed to parse hyprctl output");
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: getClients.running = true
    }

    Timer {
        id: updateDebounce
        interval: 100
        repeat: false
        onTriggered: getClients.running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            updateDebounce.restart();
        }
    }

    Component.onCompleted: getClients.running = true

    Rectangle {
        id: dock
        height: window.dockHeight
        width: parent.width
        color: Style.bg
        border.color: Style.dark4
        border.width: 1
        radius: 15
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: dockMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }

        transform: Translate {
            id: dockTranslate
            y: window.shouldHide ? window.height : 0
            Behavior on y {
                SpringAnimation {
                    spring: 7
                    damping: 0.5
                    mass: 1.5
                }
            }
        }
    }

    Rectangle {
        id: hoverRect
        width: window.width
        height: 20
        color: "transparent"
        anchors.bottom: parent.bottom

        MouseArea {
            id: activatorMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
