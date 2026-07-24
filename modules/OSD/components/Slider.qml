import QtQuick
import Quickshell
import qs.theme
import qs.components
import qs.services

Item {
    id: root
    height: 276
    width: 55
    clip: true

    required property real value
    required property string icon
    required property color surface
    required property color accent
    required property color foreground
    required property color thumbColor
    property int weight: 600

    Rectangle {
        id: body
        anchors.fill: parent
        color: root.surface
        border.color: root.accent
        radius: 15
    }

    Rectangle {
        id: thumb
        width: parent.width - 8
        height: Math.max(20,(parent.height - (icon.height + 7)) * (root.value ?? 0))
        color: root.thumbColor
        antialiasing: true
        radius: 12
        // border.color: root.color
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: icon.height + 3
        // opacity: root.value > 0 ? 1 : 0

        Behavior on height {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 50
            }
        }
    }

    Rectangle {
        id: icon
        width: parent.width
        height: 50
        color: root.accent
        anchors.bottom: parent.bottom
        bottomLeftRadius: 15
        bottomRightRadius: 15

        Symbols {
            icon: root.icon
            color: root.foreground
            anchors.centerIn: parent
            weight: root.weight
        }
    }

    InvertedCorner {
        roundingColor: root.accent
        rounding: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: icon.height
        anchors {
            bottom: parent.bottom
            bottomMargin: icon.height
        }
        rotation: 180
    }

    InvertedCorner {
        roundingColor: root.accent
        rounding: 16
        anchors {
            right: parent.right
            bottom: parent.bottom
            bottomMargin: icon.height
        }
        rotation: 90
    }
}
