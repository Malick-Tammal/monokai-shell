import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.components
import qs.theme

Item {
    id: root

    property int rounding: 25
    property color cornerColor: ColorEngine.monokai_fusion.black

    Item {
        anchors.fill: parent
        enabled: false
        z: 2

        Repeater {
            model: [
            {
                anchorTop: true,
                anchorRight: true,
                rot: 0
            },
            {
                anchorTop: true,
                anchorLeft: true,
                rot: -90
            },
            {
                anchorBottom: true,
                anchorRight: true,
                rot: 90
            },
            {
                anchorBottom: true,
                anchorLeft: true,
                rot: -180
            }
            ]

            delegate: InvertedCorner {
                anchors.top: modelData.anchorTop ? parent.top : undefined
                anchors.bottom: modelData.anchorBottom ? parent.bottom : undefined
                anchors.left: modelData.anchorLeft ? parent.left : undefined
                anchors.right: modelData.anchorRight ? parent.right : undefined

                rounding: root.rounding
                rotation: modelData.rot
                roundingColor: root.cornerColor
            }
        }
    }
}
