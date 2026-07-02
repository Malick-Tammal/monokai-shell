import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.theme
import qs.services

PopupWindow {
    id: overflowPopup
    color: "transparent"

    property Item anchorItem: null
    property var rootContext: null

    visible: rootContext ? rootContext.isExpanded : false

    implicitWidth: Screen.width
    implicitHeight: Screen.height

    anchor {
        window: rootContext ? rootContext.barWindowId : null
        item: anchorItem
    }

    MouseArea {
        anchors.fill: parent
        onPressed: if (rootContext)
        rootContext.isExpanded = false
    }

    Rectangle {
        id: popupContainer

        implicitWidth: Math.max(40, overflowGrid.implicitWidth + 20)
        implicitHeight: Math.max(40, overflowGrid.implicitHeight + 20)

        color: Style.background
        border.color: Style.border
        border.width: 1
        radius: 15

        transformOrigin: Item.Top
        opacity: overflowPopup.visible ? 1.0 : 0.0
        scale: overflowPopup.visible ? 1.0 : 0.8

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

        property bool updateTrigger: overflowPopup.visible

        x: {
            var forceUpdate = updateTrigger;
            if (!anchorItem)
            return 0;
            var globalPos = anchorItem.mapToGlobal(0, 0);
            if (!globalPos)
            return 0;
            return globalPos.x - (implicitWidth / 2) + (anchorItem.width / 2);
        }
        y: 53

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => mouse.accepted = true
        }

        GridLayout {
            id: overflowGrid
            anchors.centerIn: parent
            columns: 3
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: TrayService.items

                delegate: TrayIcon {
                    trayItem: modelData
                    rootContext: overflowPopup.rootContext

                    visible: index >= 2
                    width: visible ? 24 : 0
                    height: visible ? 24 : 0
                    Layout.preferredWidth: visible ? 24 : 0
                    Layout.preferredHeight: visible ? 24 : 0
                }
            }
        }
    }
}
