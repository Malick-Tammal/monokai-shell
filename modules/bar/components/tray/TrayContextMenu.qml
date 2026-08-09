import Quickshell
import QtQuick
import qs.core

PopupWindow {
    id: customMenu
    color: "transparent"

    property bool isOpen: false
    visible: isOpen || rootPanel.opacity > 0.01

    implicitWidth: Screen.width
    implicitHeight: Screen.height

    property var trayItem: null
    property var menuData: trayItem ? trayItem.menu : null
    property Item targetItem: null
    property var rootContext: null

    anchor {
        window: rootContext ? rootContext.barWindowId : null
        item: targetItem
    }

    onIsOpenChanged: {
        if (!rootContext)
            return;
        if (isOpen) {
            if (rootContext.activeMenu && rootContext.activeMenu !== customMenu) {
                rootContext.activeMenu.isOpen = false;
            }
            rootContext.activeMenu = customMenu;
        } else {
            if (rootContext.activeMenu === customMenu) {
                rootContext.activeMenu = null;
                GlobalStates.trayVisible = false;
            }

            if (rootPanel && rootPanel.activeSubMenuDelegate) {
                rootPanel.activeSubMenuDelegate.closeSubMenu();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            customMenu.isOpen = false;
            GlobalStates.trayVisible = false;
        }
    }

    TrayMenuPanel {
        id: rootPanel
        menuData: customMenu.menuData
        targetItem: customMenu.targetItem
        isRoot: true
        rootMenuWindow: customMenu
        isOpen: customMenu.isOpen
    }
}
