import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.theme
import qs.services
import qs.components
import QtQuick.Layouts

Item {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    height: parent.height
    width: backgroundRect.width
    visible: trayRepeater.count > 0

    property var barWindowId: null
    property var activeMenu: null

    Rectangle {
        id: backgroundRect
        height: parent.height
        width: row.implicitWidth + 10
        color: "transparent"

        Row {
            id: row
            spacing: 2
            layoutDirection: Qt.RightToLeft
            anchors.centerIn: parent

            Rectangle {
                width: 20
                height: 5
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"

                Rectangle {
                    width: 5
                    height: 5
                    anchors.centerIn: parent
                    radius: 10

                    color: Style.gray2
                }
            }

            Repeater {
                id: trayRepeater
                model: TrayService.items

                delegate: Item {
                    id: trayItemRoot
                    width: 24
                    height: 24

                    property SystemTrayItem trayItem: modelData

                    QsMenuOpener {
                        id: menuOpener
                        menu: trayItem.menu
                    }

                    PopupWindow {
                        id: customMenu
                        visible: false
                        color: "transparent"

                        implicitWidth: Screen.width
                        implicitHeight: Screen.height

                        anchor {
                            window: root.barWindowId
                            item: trayItemRoot
                        }

                        onVisibleChanged: {
                            if (visible) {
                                if (root.activeMenu && root.activeMenu !== customMenu) {
                                    root.activeMenu.visible = false;
                                }
                                root.activeMenu = customMenu;
                            } else {
                                if (root.activeMenu === customMenu) {
                                    root.activeMenu = null;
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

                            x: {
                                var globalPos = trayItemRoot.mapToGlobal(0, 0);
                                return globalPos.x - (implicitWidth / 2) + (trayItemRoot.width / 2);
                            }
                            y: 50

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
                                            iconColor: hoverArea.containsMouse ? Style.dark5 : Style.dark5
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

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Style.fg || "#ffffff"
                        opacity: trayMouseArea.containsMouse ? 0.2 : 0.0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }

                    IconImage {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: trayItem.icon
                    }

                    MouseArea {
                        id: trayMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                trayItem.activate();
                            } else if (mouse.button === Qt.RightButton) {
                                if (trayItem.hasMenu) {
                                    customMenu.visible = !customMenu.visible;
                                } else {
                                    trayItem.secondaryActivate();
                                }
                            } else if (mouse.button === Qt.MiddleButton) {
                                trayItem.secondaryActivate();
                            }
                        }
                    }
                }
            }
        }
    }
}
