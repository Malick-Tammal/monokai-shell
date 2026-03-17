import Quickshell
import QtQuick
import qs.theme

PopupWindow {
    id: tooltip

    color: "transparent"
    visible: show || tooltipRect.opacity > 0
    implicitWidth: (dockWindow && dockWindow.dockRef ? dockWindow.dockRef.width : 0) + 150
    implicitHeight: tooltipRect.height + 30

    anchor {
        window: dockWindow
        item: dockWindow ? dockWindow.dockRef : null

        edges: Edges.Top | Edges.Left
        gravity: Edges.Top | Edges.Right
    }

    required property string text
    required property bool show
    required property real targetX

    property var dockWindow: null

    property real animatedTargetX: targetX

    Behavior on animatedTargetX {
        enabled: tooltipRect.opacity > 0

        SpringAnimation {
            spring: 10
            damping: 0.5
            mass: 1.5
        }
    }

    Rectangle {
        id: tooltipRect
        color: Style.bg
        border.color: Style.border
        border.width: 1
        radius: 8

        width: tooltipText.implicitWidth + 16
        height: tooltipText.implicitHeight + 10

        opacity: tooltip.show ? 1.0 : 0.0
        scale: tooltip.show ? 1.0 : 0.6
        transformOrigin: Item.Bottom

        property real rawX: tooltip.animatedTargetX - (width / 2)
        x: Math.max(0, Math.min(rawX, tooltip.width - width))

        y: tooltip.height - height - 20

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }

        Text {
            id: tooltipText
            text: tooltip.text
            color: Style.fg
            anchors.centerIn: parent
            font {
                pixelSize: Style.fontSizeSm
                family: Style.family
                weight: Font.Normal
            }
        }
    }
}
