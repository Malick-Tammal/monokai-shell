import QtQuick
import qs.theme
import "../components/"

Item {
    id: left
    height: parent.height
    anchors.left: parent.left

    Row {
        id: row
        height: parent.height
        width: childrenRect.width
        spacing: 10
        layoutDirection: Qt.LeftToRight

        Rectangle {
            id: panel
            height: parent.height
            width: componentsRow.implicitWidth + (componentsRow.anchors.margins * 2)
            color: Style.bg
            border.color: Style.border
            radius: 15

            Row {
                id: componentsRow
                anchors.fill: parent
                spacing: 5
                layoutDirection: Qt.LeftToRight
                anchors.margins: 5

                Notification {}
                Clock {}
            }
        }

        Mode {
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
