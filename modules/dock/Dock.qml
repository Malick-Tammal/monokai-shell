import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.theme
import qs.services
import qs.core
import qs.utils
import "./components/"

PanelWindow {
    id: root
    implicitWidth: dock.width + 35
    implicitHeight: dock.height + 45
    color: "transparent"

    anchors {
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "dock"

    property bool activeHover: false
    property int hoveredIconCount: 0
    property real dockMouseX: -1

    readonly property bool isHovered: gapBridge.containsMouse || dockMouseArea.containsMouse || activatorMouseArea.containsMouse || hoveredIconCount > 0

    readonly property bool shouldHide: Intellihide.shouldHide(
        root.screen,
        Intellihide.Edge.Bottom,
        dock.width,
        dock.height,
        15
    ) && !activeHover

    Timer {
        id: hoverGraceTimer
        interval: 300
        repeat: false
        onTriggered: root.activeHover = false
    }

    onIsHoveredChanged: {
        if (isHovered) {
            hoverGraceTimer.stop();
            activeHover = true;
        } else {
            hoverGraceTimer.restart();
            root.dockMouseX = -1;
        }
    }

    property alias animY: dockTranslate.y

    mask: Region {
        x: 0
        y: {
            const hiddenY = root.implicitHeight - trigger.height;
            const dockAreaY = root.implicitHeight - dock.height - 20;
            if (root.shouldHide)
            return Math.min(dockTranslate.y, hiddenY);
            if (root.hoveredIconCount > 0)
            return Math.min(dockTranslate.y, 0);
            return Math.min(dockTranslate.y, dockAreaY);
        }
        height: root.implicitHeight - y
        width: root.width
    }

    MouseArea {
        id: gapBridge
        anchors.fill: parent
        hoverEnabled: true
    }

    //  INFO: ToolTip ---
    property string tooltipText: ""
    property real tooltipTargetX: 0
    property bool showTooltip: false
    property alias dockRef: dock

    Timer {
        id: tooltipHideTimer
        interval: 100
        repeat: false
        onTriggered: root.showTooltip = false
    }

    function updateTooltip(text, x) {
        tooltipHideTimer.stop();
        root.tooltipText = text;
        root.tooltipTargetX = x;
        root.showTooltip = true;
    }

    function cancelTooltip(text) {
        if (root.tooltipText === text) {
            tooltipHideTimer.restart();
        }
    }

    Rectangle {
        id: dock
        height: 70
        width: row.implicitWidth + 16
        color: Style.background
        border.color: Style.border
        border.width: 1
        radius: 20
        antialiasing: true
        clip: false

        opacity: DockService.isReady ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        anchors {
            bottom: parent.bottom
            bottomMargin: 15
            horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            id: dockMouseArea
            anchors.fill: parent
            hoverEnabled: true

            onPositionChanged: mouse => {
                root.dockMouseX = mapToItem(row, mouse.x, 0).x;
            }
        }

        Row {
            id: row
            spacing: 8

            anchors {
                fill: parent
                topMargin: 8
                bottomMargin: 8
                leftMargin: 8
            }

            Repeater {
                model: DockService.appList

                DockItem {
                    dockWindow: root
                    dockMouseX: root.dockMouseX
                    rowItem: row

                    onIconHoverChanged: hovered => {
                        if (hovered)
                        root.hoveredIconCount++;
                        else
                        root.hoveredIconCount--;
                    }

                    onIconMouseMoved: mappedX => {
                        root.dockMouseX = mappedX;
                    }
                }
            }
        }

        state: root.shouldHide ? "hidden" : "visible"

        transform: Translate {
            id: dockTranslate
        }

        states: [
        State {
            name: "visible"
            PropertyChanges { target: dockTranslate; y: 0 }
        },
        State {
            name: "hidden"
            PropertyChanges { target: dockTranslate; y: root.implicitHeight }
        }
        ]

        transitions: [
        Transition {
            to: "visible"
            SpringAnimation { target: dockTranslate; property: "y"; spring: 10; damping: 0.5; mass: 1.5 }
        },
        Transition {
            to: "hidden"
            SpringAnimation { target: dockTranslate; property: "y"; spring: 5; damping: 0.2; mass: 1.1 }
        }
        ]
    }

    Rectangle {
        id: trigger
        width: root.width
        height: 1
        color: "transparent"
        anchors.bottom: parent.bottom

        MouseArea {
            id: activatorMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    DockTooltip {
        dockWindow: root
        text: root.tooltipText
        show: root.showTooltip
        targetX: root.tooltipTargetX
    }
}
