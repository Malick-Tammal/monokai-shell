import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.components
import qs.core

Rectangle {
    id: panel

    property var menuData: null
    property Item targetItem: null
    property var rootMenuWindow: null
    property bool isRoot: false
    property var activeSubMenuDelegate: null
    property bool isOpen: GlobalStates.trayVisible

    implicitWidth: menuColumn.implicitWidth + 10
    implicitHeight: menuColumn.implicitHeight + 10
    color: Style.bg
    border.color: Style.border
    border.width: 1
    radius: 15

    transformOrigin: Item.Top
    opacity: GlobalStates.trayVisible ? 1.0 : 0.0
    scale: GlobalStates.trayVisible ? 1.0 : 0.8

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutBack
        }
    }

    property bool updateTrigger:GlobalStates.trayVisible

    x: {
        var forceUpdate = updateTrigger;
        if (isRoot) {
            if (!targetItem)
            return 0;
            var globalPos = targetItem.mapToGlobal(0, 0);
            if (!globalPos)
            return 0;
            return globalPos.x - (implicitWidth / 2) + (targetItem.width / 2);
        } else {
            return -implicitWidth - 10;
        }
    }

    y: {
        var forceUpdate = updateTrigger;
        if (isRoot) {
            if (!targetItem)
            return 55;
            var globalPos = targetItem.mapToGlobal(0, 0);
            if (!globalPos)
            return 55;
            return globalPos.y + targetItem.height + 20;
        } else {
            return -5;
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: mouse => mouse.accepted = true
    }

    QsMenuOpener {
        id: menuOpener
        menu: panel.menuData
    }

    ColumnLayout {
        id: menuColumn
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: menuOpener.children

            delegate: Rectangle {
                id: delegateRect
                property var menuItem: modelData
                property var subMenuPanel: null

                property bool isHoveredOrOpen: hoverArea.containsMouse || (subMenuPanel && subMenuPanel.visible)

                Layout.fillWidth: true
                Layout.minimumWidth: Math.max(180, menuItem.isSeparator ? 0 : contentRow.implicitWidth + 40)
                Layout.preferredHeight: menuItem.isSeparator ? 10 : 32
                color: isHoveredOrOpen && !menuItem.isSeparator ? ColorEngine.monokai_fusion.yellow5 : "transparent"
                radius: 10
                visible: menuItem.visible !== false

                function openSubMenu() {
                    if (!subMenuPanel) {
                        var comp = Qt.createComponent("TrayMenuPanel.qml");
                        if (comp.status === Component.Ready) {
                            subMenuPanel = comp.createObject(delegateRect, {
                                    "menuData": delegateRect.menuItem,
                                    "targetItem": delegateRect,
                                    "rootMenuWindow": panel.rootMenuWindow,
                                    "isRoot": false,
                                    "isOpen": false
                            });
                        } else {
                            console.error("Failed to load submenu panel:", comp.errorString());
                            return;
                        }
                    }
                    Qt.callLater(() => {
                            if (subMenuPanel)
                            subMenuPanel.isOpen = true;
                    });
                    panel.activeSubMenuDelegate = delegateRect;
                }

                function closeSubMenu() {
                    if (subMenuPanel) {
                        subMenuPanel.isOpen = false;
                        subMenuPanel.destroy(200);
                        subMenuPanel = null;
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 10
                    height: 1
                    color: ColorEngine.monokai_fusion.dark2
                    visible: menuItem.isSeparator === true
                }

                Row {
                    id: contentRow
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    spacing: 10
                    visible: !menuItem.isSeparator

                    IconImage {
                        width: menuItem.icon ? 16 : 0
                        height: menuItem.icon ? 16 : 0
                        anchors.verticalCenter: parent.verticalCenter
                        source: menuItem.icon || ""
                    }

                    Text {
                        text: menuItem.text || ""
                        color: isHoveredOrOpen && !menuItem.isSeparator ? ColorEngine.monokai_fusion.dark5 : Style.fg
                        anchors.verticalCenter: parent.verticalCenter
                        renderType: Text.NativeRendering
                        font {
                            family: Style.family
                            weight: Font.Normal
                            pixelSize: Style.fontSizeMd
                        }
                    }
                }

                Symbols {
                    icon: "arrow_right"
                    size: 18
                    iconColor: isHoveredOrOpen ? ColorEngine.monokai_fusion.dark5 : ColorEngine.monokai_fusion.gray2
                    visible: menuItem.hasChildren === true
                    weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    visible: !menuItem.isSeparator
                    cursorShape: Qt.PointingHandCursor

                    Timer {
                        id: hoverTimer
                        interval: 200
                        repeat: false
                        onTriggered: {
                            if (menuItem.hasChildren) {
                                delegateRect.openSubMenu();
                            }
                        }
                    }

                    onEntered: {
                        if (panel.activeSubMenuDelegate && panel.activeSubMenuDelegate !== delegateRect) {
                            panel.activeSubMenuDelegate.closeSubMenu();
                        }

                        if (menuItem.hasChildren) {
                            hoverTimer.start();
                        }
                    }

                    onExited: {
                        hoverTimer.stop();
                    }

                    onClicked: {
                        if (menuItem.hasChildren) {
                            if (delegateRect.subMenuPanel && delegateRect.subMenuPanel.isOpen) {
                                delegateRect.closeSubMenu();
                            } else {
                                delegateRect.openSubMenu();
                            }
                        } else {
                            if (typeof menuItem.triggered === "function") {
                                menuItem.triggered();
                            } else {
                                menuItem.trigger();
                            }

                            if (panel.rootMenuWindow) {
                                panel.rootMenuWindow.visible = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
