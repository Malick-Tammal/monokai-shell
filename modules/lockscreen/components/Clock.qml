import QtQuick
import qs.components
import qs.services
import qs.theme

Item {
    id: root
    height: column.height
    width: column.width

    Column {
        spacing: 0
        anchors.centerIn: parent

        Column {
            id: column
            spacing: -50
            anchors.horizontalCenter: parent.horizontalCenter

            Sliding {
                text: DateTime.hours
                size: 200
                textColor: Style.fg
                weight: Font.Black
                styleName: "Black"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Sliding {
                text: DateTime.minutes
                size: 200
                textColor: Qt.lighter(Pywal.colors.color1, 1.8)
                weight: Font.Black
                styleName: "Black"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Text {
            text: DateTime.date
            color: Style.fg
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0.8

            font {
                family: Style.family
                pixelSize: 40
                weight: Font.Bold
                styleName: "Bold"
                letterSpacing: 1
            }
        }

    }
}
