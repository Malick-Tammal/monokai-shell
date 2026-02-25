import QtQuick
import "../components/"

Item {
    id: center
    height: parent.height
    width: row.implicitWidth
    anchors.centerIn: parent

    Row {
        id: row
        anchors.fill: parent

        Workspaces {}
    }
}
