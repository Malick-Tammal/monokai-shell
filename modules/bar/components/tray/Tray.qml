import QtQuick
import qs.theme
import qs.components
import qs.services

Item {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    height: parent.height

    property bool hasItems: trayRepeater.count > 0
    property real targetWidth: hasItems ? (row.implicitWidth + 10) : 0

    width: targetWidth
    clip: true
    visible: width > 0

    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    property var barWindowId: null
    property var activeMenu: null
    property bool isExpanded: false

    Rectangle {
        id: backgroundRect
        anchors.right: parent.right
        height: parent.height
        width: row.implicitWidth + 10
        color: "transparent"

        Row {
            id: row
            spacing: 2
            layoutDirection: Qt.RightToLeft
            anchors.centerIn: parent

            DotSeparator {
                space: 20
            }

            Repeater {
                id: trayRepeater
                model: TrayService.items

                onCountChanged: {
                    if (count <= 2 && root.isExpanded) {
                        root.isExpanded = false;
                    }
                }

                delegate: TrayIcon {
                    trayItem: modelData
                    rootContext: root

                    visible: index < 2
                    width: visible ? 24 : 0
                    height: visible ? 24 : 0
                }
            }

            Rectangle {
                id: arrowContainer
                visible: trayRepeater.count > 2
                width: visible ? parent.height : 0
                height: visible ? parent.height : 0
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    color: Style.fg
                    opacity: arrowMouseArea.containsMouse ? 0.2 : 0.0
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 6
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Symbols {
                    id: arrowIcon
                    icon: "keyboard_arrow_up"
                    size: 18
                    anchors.centerIn: parent
                    color: Style.gray1
                    rotation: root.isExpanded ? 180 : 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutBack
                        }
                    }
                }

                MouseArea {
                    id: arrowMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.isExpanded = !root.isExpanded;
                    }
                }
            }
        }
    }

    TrayOverflowPopup {
        anchorItem: arrowContainer
        rootContext: root
    }
}
