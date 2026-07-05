import Quickshell
import Quickshell.Wayland
import QtQuick
import "./layouts/"
import qs.services
import qs.core
import qs.theme

PanelWindow {
    id: root
    color: "transparent"
    implicitHeight: BarService.barHeight + Style.globalPadding * 3

    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "bar"
    exclusiveZone: GlobalStates.barVisible ? (BarService.barHeight + Style.globalPadding) : 0

    property bool isIntentionallyHovered: false
    readonly property bool rawHovered: triggerHover.hovered || containerHover.hovered || gapBridge.containsMouse
    readonly property bool isHovered: !BarService.effectivelyOverlapped || isIntentionallyHovered

    Timer {
        id: hoverGraceTimer
        interval: 300
        repeat: false
        running: !triggerHover.hovered && !containerHover.hovered && !gapBridge.containsMouse
        onTriggered: isIntentionallyHovered = false
    }

    onRawHoveredChanged: {
        if (rawHovered) {
            hoverGraceTimer.stop();
            isIntentionallyHovered = true;
        }
    }

    Connections {
        target: BarService

        function onToggleRequested(targetScreenName) {
            if (root.screen.name === targetScreenName) {
                GlobalStates.barVisible = !GlobalStates.barVisible;
            }
        }

        function onRevealRequested(targetScreenName) {
            if(root.screen.name === targetScreenName) {
                GlobalStates.barVisible = true;
            }
        }

        function onHideRequested(targetScreenName) {
            if(root.screen.name === targetScreenName) {
                GlobalStates.barVisible = false;
            }
        }
    }

    mask: Region {
        x: 0
        y: 0
        width: root.width
        height: Math.max(trigger.height, BarService.barHeight + Style.globalPadding + barTranslate.y)
    }

    Item {
        id: container
        height: BarService.barHeight - 1

        readonly property bool shouldShow: (GlobalStates.barVisible || GlobalStates.trayVisible || GlobalStates.trayOverflowVisible || root.isHovered)
        state: shouldShow ? "visible" : "hidden"

        transform: Translate {
            id: barTranslate
        }

        states: [
        State {
            name: "visible"
            PropertyChanges { target: barTranslate; y: 0 }
        },
        State {
            name: "hidden"
            PropertyChanges { target: barTranslate; y: -BarService.barHeight * 2 }
        }
        ]

        transitions: [
        Transition {
            to: "visible"
            SpringAnimation { target: barTranslate; property: "y"; spring: 10; damping: 0.5; mass: 1.5 }
        },
        Transition {
            to: "hidden"
            SpringAnimation { target: barTranslate; property: "y"; spring: 5; damping: 0.2; mass: 1.1 }
        }
        ]

        HoverHandler {
            id: containerHover
        }

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Style.globalPadding + 1
            leftMargin:Style.globalPadding
            rightMargin: Style.globalPadding
        }

        Right {
            barWindowId: root
        }
        Center {}
        Left {}
    }

    Rectangle {
        id: bridge
        width: root.width
        height: BarService.barHeight + Style.globalPadding
        color: "transparent"
        anchors.top: parent.top
        visible: barTranslate.y > (-BarService.barHeight * 2)
        z: -1

        MouseArea {
            id: gapBridge
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    Rectangle {
        id: trigger
        width: root.width
        height: 1
        color: "transparent"
        anchors.top: parent.top
        z: -1

        HoverHandler {
            id: triggerHover
        }
    }
}
