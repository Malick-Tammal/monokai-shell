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
    property bool allowEmpty: false

    property bool _dragging: false
    property bool hovered: hoverHandler.hovered

    signal valueChangeRequested(real newValue)

    HoverHandler {
        id: hoverHandler
    }

    readonly property real _trackHeight: root.height - iconRect.height - 7

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
        height: root.allowEmpty ? _trackHeight * (root.value ?? 0) : Math.max(20, _trackHeight * (root.value ?? 0))
        color: root.thumbColor
        antialiasing: true
        radius: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: iconRect.height + 3

        Behavior on height {
            enabled: !root._dragging
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
        id: iconRect
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
        anchors {
            bottom: parent.bottom
            bottomMargin: iconRect.height
        }
        rotation: 180
    }

    InvertedCorner {
        roundingColor: root.accent
        rounding: 16
        anchors {
            right: parent.right
            bottom: parent.bottom
            bottomMargin: iconRect.height
        }
        rotation: 90
    }

    Item {
        id: track

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: iconRect.top
        }

        DragHandler {
            id: dragHandler
            target: null
            xAxis.enabled: false
            yAxis.enabled: true
            dragThreshold: 0
            cursorShape: Qt.SizeVerCursor

            onActiveChanged: {
                root._dragging = active;
                if (active) {
                    const v = 1.0 - Math.max(0.0, Math.min(1.0, centroid.position.y / root._trackHeight));
                    root.valueChangeRequested(v);
                }
            }

            onCentroidChanged: {
                if (active) {
                    const v = 1.0 - Math.max(0.0, Math.min(1.0, centroid.position.y / root._trackHeight));
                    root.valueChangeRequested(v);
                }
            }
        }

        TapHandler {
            onTapped: eventPoint => {
                const y = track.mapFromGlobal(eventPoint.scenePosition.x, eventPoint.scenePosition.y).y;
                const v = 1.0 - Math.max(0.0, Math.min(1.0, y / root._trackHeight));
                root.valueChangeRequested(v);
            }
        }

        WheelHandler {
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const step = 0.05;
                const delta = event.angleDelta.y > 0 ? step : -step;
                const v = Math.max(0.0, Math.min(1.0, root.value + delta));
                root.valueChangeRequested(v);
            }
        }
    }
}
