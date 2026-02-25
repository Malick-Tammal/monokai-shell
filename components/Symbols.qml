import QtQuick
import qs.theme

Text {
    id: root

    property string icon: ""
    property int size: 24
    property color iconColor: Style.fg
    property int weight: Font.Normal

    FontLoader {
        id: materialFont
        source: "../assets/MaterialSymbolsRounded.ttf"
    }

    text: icon
    color: iconColor

    renderType: Text.NativeRendering

    font {
        family: materialFont.name
        pixelSize: size
        variableAxes: {
            "wght": weight,
            "FILL": true,
            "GRAD": 200,
            "opsz": size
        }
    }
}
