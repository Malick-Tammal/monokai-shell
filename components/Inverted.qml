import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root
    implicitWidth: rounding
    implicitHeight: rounding

    property color roundingColor
    property int rounding: 20

    MultiEffect {
        source: background
        anchors.fill: background
        maskEnabled: true
        maskSource: mask

        // Force the effect to render at high quality
        layer.enabled: true
        layer.smooth: true
        layer.samples: 8 // High sampling = no pixelation

        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    Rectangle {
        id: background
        anchors.fill: parent
        visible: false
        smooth: true
        color: root.roundingColor
    }

    Shape {
        id: mask
        anchors.fill: parent
        visible: false

        // This makes the internal vector rendering high-quality
        layer.enabled: true
        layer.samples: 8

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            fillColor: "black" // Must have a fill to act as a mask

            startX: 0
            startY: 0

            PathArc {
                radiusX: root.rounding
                radiusY: root.rounding
                useLargeArc: false
                x: root.rounding
                y: root.rounding
            }
            PathLine {
                x: root.rounding
                y: 0
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }
}
