import Quickshell.Widgets
import QtQuick
import qs.theme
import qs.core

Item {
    id: trayItemRoot
    width: 30
    height: 30

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
        color: Style.textPrimary
        opacity: trayMouseArea.containsMouse ? 0.2 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    Image {
        id: icon

        width: 20
        height: width
        anchors.centerIn: parent

        source: trayItemRoot.trayItem ? trayItemRoot.trayItem.icon : ""

        sourceSize.width: width * 2
        sourceSize.height: height * 2

        smooth: true
        mipmap: true
        asynchronous: true
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
                    GlobalStates.trayVisible = !GlobalStates.trayVisible;
                } else {
                    trayItemRoot.trayItem.secondaryActivate();
                }
            } else if (mouse.button === Qt.MiddleButton) {
                trayItemRoot.trayItem.secondaryActivate();
            }
        }
    }
}
