import QtQuick
import qs.theme

Text {
    id: root

    property string icon: ""
    property int size: 12
    property color iconColor: Style.textPrimary
    property int weight: Font.Bold

    text: icon
    color: iconColor

    font {
        family: Style.nerdFamily
        pixelSize: size
        weight: weight
    }
}
