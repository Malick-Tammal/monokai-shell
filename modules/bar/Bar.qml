import Quickshell
import Quickshell.Wayland
import QtQuick
import "./modules/"
import qs.services
import qs

PanelWindow {
    id: root
    color: "transparent"

    property int bounceBuffer: 10
    readonly property bool isHovered: !BarService.effectivelyOverlapped || triggerHover.hovered || containerHover.hovered || gapBridge.containsMouse

    MouseArea {
        id: gapBridge
        anchors.fill: parent
        hoverEnabled: true
    }

    implicitHeight: BarService.barHeight + GlobalStates.padding + bounceBuffer

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "bar"
    exclusiveZone: GlobalStates.barVisible ? (BarService.barHeight + GlobalStates.padding) : 0

    anchors {
        top: true
        left: true
        right: true
    }

    mask: Region {
        x: 0
        y: 0
        width: root.width
        height: Math.max(trigger.height, BarService.barHeight + GlobalStates.padding + root.bounceBuffer + barTranslate.y)
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
        height: BarService.barHeight

        transform: Translate {
            id: barTranslate
            readonly property bool shouldShow: GlobalStates.barVisible || root.isHovered

            y: shouldShow ? 0 : -BarService.barHeight * 2

            Behavior on y {
                SpringAnimation {
                    spring: 10
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
