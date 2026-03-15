import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.theme
import qs.services
import qs
import "./components/"

PanelWindow {
    id: root
    implicitWidth: dock.width + 35
    implicitHeight: dock.height + 62
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "dock"

    anchors {
        bottom: true
    }

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

    property alias animY: dockTranslate.y

    //  INFO: INTELLIHIDE
    readonly property bool overlapsWindow: {
        if (Hypr.windowList.length === 0)
            return false;

        const dockTopEdge = (root.screen.y + root.screen.height) - dock.height - (GlobalStates.padding + 3);
        const currentWsId = Hyprland.focusedWorkspace?.id ?? -999;

        return Hypr.windowList.some(win => {
            if (win.workspace.id !== currentWsId)
                return false;
            if (win.at[0] === -32000)
                return false;

            const winBottomEdge = win.at[1] + win.size[1];
            return winBottomEdge > dockTopEdge;
        });
    }

    property bool activeHover: false
    property int hoveredIconCount: 0
    property real dockMouseX: -1

    readonly property bool isHovered: gapBridge.containsMouse || dockMouseArea.containsMouse || activatorMouseArea.containsMouse || hoveredIconCount > 0
    readonly property bool shouldHide: overlapsWindow && !activeHover

    Timer {
        id: hideTimer
        interval: 300
        repeat: false
        onTriggered: root.activeHover = false
    }

    onIsHoveredChanged: {
        if (isHovered) {
            hideTimer.stop();
            activeHover = true;
        } else {
            hideTimer.restart();
            root.dockMouseX = -1;
        }
    }

    Rectangle {
        id: dock
        height: 60
        width: row.implicitWidth + 16
        color: Style.bg
        border.color: Style.border
        border.width: 1
        radius: 15
        clip: false

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

        transform: Translate {
            id: dockTranslate
            y: root.shouldHide ? root.implicitHeight : 0
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
}
