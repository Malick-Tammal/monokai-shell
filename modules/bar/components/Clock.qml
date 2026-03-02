import QtQuick
import qs.components
import qs.services
import qs.theme

Item {
    id: root

    height: parent.height
    width: con.width

    Rectangle {
        id: con
        width: row.width
        height: parent.height
        radius: 10
        color: "transparent"

        Row {
            id: row
            anchors.centerIn: parent

            Sliding {
                text: DateTime.hours
                size: 20
                color: Style.yellow5
            }

            Text {
                text: ":"
                color: Style.fg
                renderType: Text.NativeRendering
                anchors.horizontalCenterOffset: 0
                y: -1

                font {
                    pixelSize: 20
                    family: Style.family
                    weight: Font.Black
                }
            }

            Sliding {
                text: DateTime.minutes
                size: 20
            }
        }
    }
}
