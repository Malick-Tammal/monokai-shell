import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services

Row {
    id: root

    required property var modelData
    required property int index
    required property real dockMouseX
    required property Item rowItem

    signal iconHoverChanged(bool hovered)
    signal iconMouseMoved(real mappedX)

    property int appCount: modelData.count
    property bool isLaunching: false
    property real bounceOffset: 0

    onAppCountChanged: {
        if (appCount > 0 && isLaunching) {
            isLaunching = false;
            launchTimeout.stop();
        }
    }

    Timer {
        id: launchTimeout
        interval: 10000
        repeat: false
        onTriggered: {
            root.isLaunching = false;
        }
    }

    SequentialAnimation on bounceOffset {
        id: bounceAnim
        running: root.isLaunching
        loops: Animation.Infinite

        NumberAnimation {
            to: -30
            duration: 300
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            to: 0
            duration: 300
            easing.type: Easing.InQuad
        }
    }

    height: parent.height
    spacing: separator.visible ? 8 : 0

    Rectangle {
        id: separator
        width: 3
        height: parent.height * 0.6
        anchors.verticalCenter: parent.verticalCenter
        color: Style.dark1
        radius: 1
        visible: !root.modelData.isPinned && root.index > 0 && DockService.appList[root.index - 1].isPinned
    }

    Item {
        id: iconSlot
        width: parent.height
        height: parent.height + 24
        anchors.bottom: parent.bottom

        readonly property real iconCenterX: root.x + x + width / 2

        IconImage {
            source: Quickshell.iconPath(DockService.getIconName(root.modelData.class), true)
            width: parent.width
            height: parent.width
            anchors.bottom: parent.bottom
            smooth: true
            transformOrigin: Item.Bottom

            scale: {
                if (iconMouseArea.pressed)
                    return 0.9;
                if (root.dockMouseX < 0)
                    return 1.0;
                const pixelDist = Math.abs(root.dockMouseX - iconSlot.iconCenterX);
                const radius = 100;
                const maxScale = 1.3;
                if (pixelDist >= radius)
                    return 1.0;
                return 1.0 + (maxScale - 1.0) * (1 + Math.cos(Math.PI * pixelDist / radius)) / 1.5;
            }

            Behavior on scale {
                SpringAnimation {
                    spring: 10
                    damping: 0.5
                    mass: 1.5
                }
            }

            transform: [
                Translate {
                    y: {
                        if (iconMouseArea.pressed)
                            return 2;
                        if (root.dockMouseX < 0)
                            return 0;
                        const pixelDist = Math.abs(root.dockMouseX - iconSlot.iconCenterX);
                        const radius = 120;
                        const maxLift = -8;
                        if (pixelDist >= radius)
                            return 0;
                        return maxLift * (1 + Math.cos(Math.PI * pixelDist / radius)) / 2;
                    }

                    Behavior on y {
                        SmoothedAnimation {
                            velocity: 100
                        }
                    }
                },
                Translate {
                    y: root.bounceOffset
                }
            ]
        }

        DockTooltip {
            text: DockService.getDisplayName(root.modelData.class)
            show: iconMouseArea.containsMouse
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
                model: root.modelData.count

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

            onPositionChanged: mouse => {
                root.iconMouseMoved(mapToItem(root.rowItem, mouse.x, 0).x);
            }

            onContainsMouseChanged: {
                root.iconHoverChanged(containsMouse);
            }

            Component.onDestruction: {
                if (containsMouse) {
                    root.iconHoverChanged(false);
                }
            }

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    if (root.modelData.count > 0) {
                        Hyprland.dispatch(`focuswindow address:${root.modelData.windows[0].address}`);
                    } else if (root.modelData.isPinned) {
                        if (root.isLaunching)
                            return;
                        root.isLaunching = true;
                        launchTimeout.restart();
                        Hyprland.dispatch(`exec ${root.modelData.exec}`);
                    }
                } else if (mouse.button === Qt.MiddleButton) {
                    if (root.modelData.count > 0) {
                        Hyprland.dispatch(`closewindow address:${root.modelData.windows[0].address}`);
                    }
                }
            }
        }
    }
}
