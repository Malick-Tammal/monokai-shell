import QtQuick
import qs.theme
import qs.components
import qs.core

Item {
    id: root
    height: parent.height
    width: parent.height

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: hoverHandler.hovered ? ColorEngine.monokai_fusion.red4 : Style.error
        border.color: Style.errorBorder

        Symbols {
            icon : "mode_off_on"
            size: Style.symbolSize
            color: Style.textOnError

            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
        }

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                GlobalStates.powerMenuVisible = !GlobalStates.powerMenuVisible;
            }
        }
    }
}
