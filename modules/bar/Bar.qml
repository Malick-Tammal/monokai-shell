import Quickshell
import Quickshell.Wayland
import QtQuick
import "./modules/"
import qs.services
import qs

PanelWindow {
    id: root
    color: "transparent"

    property int bounceBuffer: 5
    readonly property bool isHovered: !GlobalStates.barOverlapsWindow || triggerHover.hovered || containerHover.hovered || gapBridge.containsMouse

    MouseArea {
        id: gapBridge
        anchors.fill: parent
        hoverEnabled: true
    }

    implicitHeight: GlobalStates.barHeight + GlobalStates.padding + bounceBuffer

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "bar"
    exclusiveZone: GlobalStates.barVisible ? (GlobalStates.barHeight + GlobalStates.padding) : 0

    anchors {
        top: true
        left: true
        right: true
    }

    mask: Region {
        x: 0
        y: 0
        width: root.width
        height: Math.max(trigger.height, GlobalStates.barHeight + GlobalStates.padding + root.bounceBuffer + barTranslate.y)
    }

    Connections {
        target: BarService

        function onToggleRequested(targetScreenName) {
            if (root.screen.name === targetScreenName) {
                GlobalStates.barVisible = !GlobalStates.barVisible;
            }
        }
    }

    Item {
        id: container
        height: GlobalStates.barHeight

        transform: Translate {
            id: barTranslate
            y: (GlobalStates.barVisible || root.isHovered) ? 0 : -GlobalStates.barHeight * 2

            Behavior on y {
                SpringAnimation {
                    spring: 7
                    damping: 0.5
                    mass: 1.5
                }
            }
        }

        HoverHandler {
            id: containerHover
        }

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: GlobalStates.padding
            leftMargin: GlobalStates.padding
            rightMargin: GlobalStates.padding
        }

        Right {
            barWindowId: root
        }
        Center {}
        Left {}
    }

    Rectangle {
        id: trigger
        width: root.width
        height: 1
        color: "transparent"
        anchors.top: parent.top

        HoverHandler {
            id: triggerHover
        }
    }
}
