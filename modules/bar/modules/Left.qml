import QtQuick
import qs.theme
import "../components/"

Item {
    id: left
    height: parent.height
    width: row.implicitWidth + (row.anchors.margins * 2)
    anchors.left: parent.left

    Rectangle {
        id: panel
        anchors.fill: parent

        color: Style.bg
        border.color: Style.border
        radius: 15
    }

    Row {
        id: row
        anchors.fill: parent
        spacing: 5
        layoutDirection: Qt.LeftToRight
        anchors.margins: 5

        Clock {}
    }
}
