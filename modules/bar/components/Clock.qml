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
        width: Math.max(130, row.width)
        height: parent.height
        radius: 10
        color: "transparent"

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 3

            Sliding {
                text: DateTime.hours
                size: Style.fontSize2Xl
                textColor: Style.yellow5
                weight: Font.Black
                styleName: "Black"
            }

            Text {
                text: ":"
                color: Style.fg
                anchors.horizontalCenterOffset: 0
                y: -1

                renderType: Text.NativeRendering
                renderTypeQuality: Text.VeryHighRenderTypeQuality

                font {
                    pixelSize: Style.fontSize2Xl
                    family: Style.family
                    weight: Font.Black
                    styleName: "Black"
                }
            }

            Sliding {
                text: DateTime.minutes
                size: Style.fontSize2Xl
                textColor: Style.fg
                weight: Font.Black
                styleName: "Black"
            }

            Text {
                text: DateTime.ampm
                color: Style.gray1
                width: contentWidth + 10
                horizontalAlignment: Text.AlignHCenter

                renderType: Text.NativeRendering
                renderTypeQuality: Text.VeryHighRenderTypeQuality

                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 1
                }

                font {
                    pixelSize: Style.fontSizeMd
                    family: Style.family
                    weight: Font.Black
                    styleName: "Black"
                }
            }
        }
    }
}
