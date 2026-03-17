import QtQuick
import qs.theme

Item {
    id: root

    property int space: 10

    implicitWidth: space
    implicitHeight: parent.height
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        width: 5
        height: 5
        anchors.centerIn: parent
        color: Style.gray2
        radius: 10
    }
}
