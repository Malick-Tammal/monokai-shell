import QtQuick
import qs.theme
import "../components/"

Item {
    id: right
    height: parent.height
    width: row.implicitWidth + (row.anchors.margins * 2)
    anchors.right: parent.right

    property var barWindowId

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
        Network {}
        Bluetooth {}
        Audio {}
        // Tray {}
        Tray {
            barWindowId: right.barWindowId
        }
    }
}
