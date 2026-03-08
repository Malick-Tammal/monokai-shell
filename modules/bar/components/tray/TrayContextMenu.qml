import Quickshell
import QtQuick

PopupWindow {
    id: customMenu
    color: "transparent"
    visible: false

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

            if (rootPanel && rootPanel.activeSubMenuDelegate) {
                rootPanel.activeSubMenuDelegate.closeSubMenu();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: customMenu.visible = false
    }

    TrayMenuPanel {
        id: rootPanel
        menuData: customMenu.menuData
        targetItem: customMenu.targetItem
        isRoot: true
        rootMenuWindow: customMenu
        isOpen: customMenu.visible
    }
}
