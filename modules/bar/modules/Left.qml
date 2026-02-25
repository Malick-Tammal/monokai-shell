import QtQuick
import qs.theme

Item {
    id: left
    height: parent.height
    width: 200
    anchors.left: parent.left

    Rectangle {
        id: panel
        anchors.fill: parent

        color: Style.bg
        border.color: Style.border
        radius: 15
    }
}
