import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services

PanelWindow {
    id: root
    implicitWidth: dock.width
    implicitHeight: dock.height + 20
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors {
        bottom: true
    }

    mask: Region {
        x: 0
        y: Math.min(dockTranslate.y, root.implicitHeight - trigger.height)
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
        if (DockService.windowList.length === 0)
            return false;

        const dockTopEdge = (root.screen.y + root.screen.height) - root.implicitHeight + 5;
        const currentWsId = Hyprland.focusedWorkspace?.id ?? -999;

        return DockService.windowList.some(win => {
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
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: dockMouseArea
            anchors.fill: parent
            hoverEnabled: true
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

                Row {
                    height: row.height
                    spacing: separator.visible ? 8 : 0

                    Rectangle {
                        id: separator
                        width: 3
                        height: parent.height * 0.6
                        anchors.verticalCenter: parent.verticalCenter
                        color: Style.dark1
                        radius: 1
                        visible: !modelData.isPinned && index > 0 && DockService.appList[index - 1].isPinned
                    }

                    Item {
                        width: parent.height
                        height: parent.height

                        IconImage {
                            source: Quickshell.iconPath(DockService.getIconName(modelData.class), true)
                            anchors.fill: parent
                            smooth: false
                            scale: {
                                if (iconMouseArea.pressed)
                                    return 0.9;
                                if (iconMouseArea.containsMouse)
                                    return 1.2;
                                return 1.0;
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 4.0
                                }
                            }

                            transform: Translate {
                                y: {
                                    if (iconMouseArea.pressed)
                                        return 2;
                                    if (iconMouseArea.containsMouse)
                                        return -10;
                                    return 0;
                                }

                                Behavior on y {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 2.0
                                    }
                                }
                            }
                        }

                        RowLayout {
                            width: dotRepeater.count > 2 ? parent.width : implicitWidth
                            clip: true
                            spacing: 2

                            anchors {
                                bottom: parent.bottom
                                bottomMargin: -5
                                horizontalCenter: parent.horizontalCenter
                            }

                            Repeater {
                                id: dotRepeater
                                model: modelData.count

                                Rectangle {
                                    Layout.fillWidth: dotRepeater.count > 2
                                    Layout.preferredWidth: 10
                                    height: 4
                                    radius: 20
                                    color: Style.yellow5
                                }
                            }
                        }

                        MouseArea {
                            id: iconMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.CursorShape.PointingHandCursor

                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

                            onContainsMouseChanged: {
                                if (containsMouse) {
                                    root.hoveredIconCount++;
                                } else {
                                    root.hoveredIconCount--;
                                }
                            }

                            Component.onDestruction: {
                                if (containsMouse) {
                                    root.hoveredIconCount--;
                                }
                            }

                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton) {
                                    if (modelData.count > 0) {
                                        Hyprland.dispatch(`focuswindow address:${modelData.windows[0].address}`);
                                    } else if (modelData.isPinned) {
                                        Hyprland.dispatch(`exec ${modelData.exec}`);
                                    }
                                } else if (mouse.button === Qt.MiddleButton) {
                                    if (modelData.count > 0) {
                                        Hyprland.dispatch(`closewindow address:${modelData.windows[0].address}`);
                                    }
                                }
                            }
                        }
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
