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
        width: Math.max(100, row.width)
        height: parent.height
        radius: 10
        color: "transparent"

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 3

            Sliding {
                text: DateTime.hours
                size: 20
                textColor: Style.yellow5
            }

            Text {
                text: ":"
                color: Style.fg
                renderType: Text.QtRendering
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

            Text {
                text: DateTime.ampm
                color: Style.gray1
                renderType: Text.NativeRendering
                width: contentWidth + 5
                horizontalAlignment: Text.AlignHCenter
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 2
                }

                font {
                    pixelSize: 12
                    family: Style.family
                    weight: Font.Black
                }
            }
        }
    }
}
