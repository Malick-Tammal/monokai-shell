import Qt5Compat.GraphicalEffects

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.core

Row {
    id: root

    height: Configs.dockIconSize
    spacing: separator.visible ? 8 : 0

    required property var modelData
    required property int index
    required property real dockMouseX
    required property Item rowItem
    property var dockWindow: null

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
            to: -20
            duration: 300
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            to: 0
            duration: 300
            easing.type: Easing.InQuad
        }
    }

    Rectangle {
        id: separator
        width: 3
        height: parent.height * 0.6
        anchors.verticalCenter: parent.verticalCenter
        color: Style.divider
        radius: 1
        antialiasing: true
        visible: !root.modelData.isPinned && root.index > 0 && DockService.appList[root.index - 1].isPinned
    }

    Item {
        id: iconSlot
        width: parent.height
        height: parent.height + 24
        anchors.bottom: parent.bottom

        readonly property real iconCenterX: root.x + x + width / 2
        property string resolvedIconName: DockService.getCachedIconName(root.modelData.class)
        property bool isIconReady: resolvedIconName !== ""

        Timer {
            id: lazyLoadTimer
            interval: 100 + (root.index * 15)
            running: iconSlot.resolvedIconName === ""
            repeat: false
            onTriggered: {
                iconSlot.resolvedIconName = DockService.getIconName(root.modelData.class);
            }
        }

        Timer {
            id: fadeInDelay
            interval: 200
            repeat: false
            onTriggered: iconSlot.isIconReady = true
        }

        Rectangle {
            id: iconPlaceholder
            width: parent.width * 0.9
            height: parent.width * 0.9
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: parent.width * 0.05
            }
            radius: width / 4
            color: Style.surfaceAlt
            opacity: iconSlot.isIconReady ? 0 : 1
            antialiasing: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }

        Loader {
            active: iconSlot.isIconReady
            width: parent.width
            height: parent.width
            anchors.bottom: parent.bottom
            opacity: iconSlot.isIconReady ? 1 : 1

            onStatusChanged: {
                if (status === Image.Ready && !iconSlot.isIconReady) {
                    fadeInDelay.restart();
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            sourceComponent: Item {
                anchors.fill: parent
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

                Loader {
                    id: iconLoader
                    anchors.fill: parent
                    sourceComponent: IconImage {
                        id: actualIcon
                        source: Quickshell.iconPath(iconSlot.resolvedIconName === "" ? "unknown" : iconSlot.resolvedIconName, true)
                    }
                }

                Loader {
                    id: overlayLoader
                    active: Configs.tintedDockIcons
                    anchors.fill: iconLoader
                    sourceComponent: Item {
                        Desaturate {
                            id: desaturatedIcon
                            desaturation: 0.5
                            source: iconLoader
                            anchors.fill: parent
                            visible: false
                        }
                        ColorOverlay {
                            source: desaturatedIcon
                            color: ColorEngine.withAlpha(Style.primary, 0.9)
                            anchors.fill: desaturatedIcon
                        }
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
                model: root.modelData.count

                Rectangle {
                    Layout.fillWidth: dotRepeater.count > 2
                    Layout.preferredWidth: 10
                    height: 4
                    radius: 20
                    antialiasing: true
                    color: Style.primary
                    visible: root.modelData.windows[index]?.workspace?.name !== "special:hidden"
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

                if (containsMouse) {
                    let mapped = iconSlot.mapToItem(root.dockWindow.dockRef, iconSlot.width / 2, 0);
                    root.dockWindow.updateTooltip(DockService.getDisplayName(root.modelData.class), mapped.x);
                } else {
                    root.dockWindow.cancelTooltip(DockService.getDisplayName(root.modelData.class));
                }
            }

            Component.onDestruction: {
                if (containsMouse) {
                    root.iconHoverChanged(false);
                }
            }

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    const firstWin = root.modelData.count > 0 ? root.modelData.windows[0] : null;
                    const isSpecialHidden = firstWin?.workspace?.name === "special:hidden";

                    if (firstWin && !isSpecialHidden) {
                        const winAddress = firstWin.address;
                        Hyprland.dispatch(`hl.dsp.focus({window = "address:${winAddress}"})`);
                        Hyprland.dispatch(`hl.dsp.window.bring_to_top({window = "address:${winAddress}"})`);
                    } else if (root.modelData.isPinned || isSpecialHidden) {
                        if (root.isLaunching)
                            return;
                        root.isLaunching = true;
                        launchTimeout.restart();
                        DockService.launchApp(root.modelData.class, root.modelData.exec);
                    }
                } else if (mouse.button === Qt.MiddleButton) {
                    if (root.modelData.count > 0) {
                        Hyprland.dispatch(`hl.dsp.window.close({window = "address:${root.modelData.windows[0].address}"})`);
                    }
                }
            }
        }
    }
}
