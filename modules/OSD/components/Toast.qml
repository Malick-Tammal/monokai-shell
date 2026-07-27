import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.theme

Item {
    id: root

    required property string icon
    required property string text
    required property color accentColor
    required property color surfaceColor
    required property color lightSurfaceColor

    height: 65
    width: wrapper.width

    Rectangle {
        id: wrapper
        width: row.implicitWidth + 2
        height: parent.height
        color: root.accentColor
        radius: 15
        transformOrigin: Item.Center

        RowLayout {
            id: row
            spacing: 0
            height: parent.height - 2
            anchors.centerIn: parent

            Rectangle {
                id: icon
                color: root.accentColor
                width: symbol.width + 35
                height: parent.height
                topLeftRadius: 15
                bottomLeftRadius: 15

                Symbols {
                    id: symbol
                    icon: root.icon
                    size: 26
                    color: root.surfaceColor
                    anchors.centerIn: parent
                }
            }

            Rectangle {
                id: textIndicator
                color: root.surfaceColor
                implicitWidth: text.implicitWidth + 60
                height: parent.height
                radius: 15

                Text {
                    id: text
                    text: root.text
                    anchors.centerIn: parent
                    color: root.lightSurfaceColor

                    font {
                        pixelSize: 23
                        weight: Font.Bold
                        styleName: "Bold"
                        family: Style.family
                    }
                }
            }
        }
    }
}
