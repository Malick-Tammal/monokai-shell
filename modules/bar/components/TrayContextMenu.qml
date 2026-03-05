import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.components

PopupWindow {
    id: customMenu
    color: "transparent"
    visible: false

    implicitWidth: Screen.width
    implicitHeight: Screen.height

    property var trayItem: null
    property Item targetItem: null
    property var rootContext: null

    anchor {
        window: rootContext ? rootContext.barWindowId : null
        item: targetItem
    }

    QsMenuOpener {
        id: menuOpener
        menu: customMenu.trayItem ? customMenu.trayItem.menu : null
    }

    onVisibleChanged: {
        if (!rootContext)
            return;
        if (visible) {
            if (rootContext.activeMenu && rootContext.activeMenu !== customMenu) {
                rootContext.activeMenu.visible = false;
            }
            rootContext.activeMenu = customMenu;
        } else {
            if (rootContext.activeMenu === customMenu) {
                rootContext.activeMenu = null;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: customMenu.visible = false
    }

    Rectangle {
        id: container
        implicitWidth: menuColumn.implicitWidth + 10
        implicitHeight: menuColumn.implicitHeight + 10
        color: Style.bg
        border.color: Style.border
        border.width: 1
        radius: 15

        transformOrigin: Item.Top
        opacity: customMenu.visible ? 1.0 : 0.0
        scale: customMenu.visible ? 1.0 : 0.8

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

        property bool updateTrigger: customMenu.visible

        x: {
            var forceUpdate = updateTrigger;
            if (!targetItem)
                return 0;
            var globalPos = targetItem.mapToGlobal(0, 0);
            if (!globalPos)
                return 0;
            return globalPos.x - (implicitWidth / 2) + (targetItem.width / 2);
        }

        y: {
            var forceUpdate = updateTrigger;
            if (!targetItem)
                return 55;
            var globalPos = targetItem.mapToGlobal(0, 0);
            if (!globalPos)
                return 55;
            return globalPos.y + targetItem.height + 20;
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        ColumnLayout {
            id: menuColumn
            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: menuOpener.children

                delegate: Rectangle {
                    property var menuItem: modelData
                    Layout.fillWidth: true
                    Layout.minimumWidth: Math.max(180, menuItem.isSeparator ? 0 : contentRow.implicitWidth + 40)
                    Layout.preferredHeight: menuItem.isSeparator ? 10 : 32
                    color: hoverArea.containsMouse && !menuItem.isSeparator ? Style.yellow5 : "transparent"
                    radius: 10
                    visible: menuItem.visible !== false

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 10
                        height: 1
                        color: Style.dark2
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
                            color: hoverArea.containsMouse && !menuItem.isSeparator ? Style.dark5 : Style.fg
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
                        iconColor: hoverArea.containsMouse ? Style.dark5 : Style.gray2
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

                        onClicked: {
                            if (menuItem.hasChildren) {
                                menuItem.display(customMenu, 0, 0);
                            } else {
                                if (typeof menuItem.triggered === "function") {
                                    menuItem.triggered();
                                } else {
                                    menuItem.trigger();
                                }
                                customMenu.visible = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
