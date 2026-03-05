import Quickshell.Widgets
import QtQuick
import qs.theme

Item {
    id: trayItemRoot
    width: 24
    height: 24

    property var trayItem: null
    property var rootContext: null

    TrayContextMenu {
        id: customMenu
        trayItem: trayItemRoot.trayItem
        targetItem: trayItemRoot
        rootContext: trayItemRoot.rootContext
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
        source: trayItemRoot.trayItem ? trayItemRoot.trayItem.icon : ""
    }

    MouseArea {
        id: trayMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
            if (!trayItemRoot.trayItem)
                return;
            if (mouse.button === Qt.LeftButton) {
                trayItemRoot.trayItem.activate();
            } else if (mouse.button === Qt.RightButton) {
                if (trayItemRoot.trayItem.hasMenu) {
                    customMenu.visible = !customMenu.visible;
                } else {
                    trayItemRoot.trayItem.secondaryActivate();
                }
            } else if (mouse.button === Qt.MiddleButton) {
                trayItemRoot.trayItem.secondaryActivate();
            }
        }
    }
}
