import Quickshell
import QtQuick
import "../../../theme/"
import "../components/"

Item {
    id: right
    height: parent.height
    width: row.childrenRect.width + (row.anchors.margins * 2)
    anchors.right: parent.right

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
        layoutDirection: Qt.RightToLeft
        anchors.margins: 5

        Power {}
        Battery {}
    }
}
