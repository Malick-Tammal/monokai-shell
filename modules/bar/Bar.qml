import Quickshell
import Quickshell.Wayland
import QtQuick
import "./layouts/"
import qs.services
import qs.core

PanelWindow {
    id: root
    color: "transparent"
    implicitHeight: BarService.barHeight + GlobalStates.padding + bounceBuffer

    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "bar"
    exclusiveZone: GlobalStates.barVisible ? (BarService.barHeight + GlobalStates.padding) : 0

    //  TIP: This is a hack to prevent the bar from clipping when it's hovered
    property int bounceBuffer: 10

    //  INFO: Hover logic (fixed intented mouse movement out and in)
    property bool activeHover: false
    readonly property bool rawHovered: triggerHover.hovered || containerHover.hovered || gapBridge.containsMouse
    readonly property bool isHovered: !BarService.effectivelyOverlapped || activeHover

    Timer {
        id: hoverIntentTimer
        interval: 200
        repeat: false
        onTriggered: root.activeHover = true
    }

    Timer {
        id: hideGraceTimer
        interval: 300
        repeat: false
        onTriggered: root.activeHover = false
    }

    onRawHoveredChanged: {
        if (rawHovered) {
            hideGraceTimer.stop();

            if (root.activeHover || !BarService.effectivelyOverlapped || GlobalStates.barVisible) {
                root.activeHover = true;
            } else {
                hoverIntentTimer.restart();
            }
        } else {
            hoverIntentTimer.stop();
            hideGraceTimer.restart();
        }
    }

    MouseArea {
        id: gapBridge
        anchors.fill: parent
        hoverEnabled: true
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
        height: BarService.barHeight - 2

        transform: Translate {
            id: barTranslate
            readonly property bool shouldShow: GlobalStates.barVisible || root.isHovered

            y: shouldShow ? 0 : -BarService.barHeight * 2

            Behavior on y {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.8
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
            topMargin: GlobalStates.padding + 1
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
