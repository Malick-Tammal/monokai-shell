import QtQuick
import qs.theme

Text {
    id: root

    property string icon: ""
    property int size: 24
    property color iconColor: Style.fg
    property int weight: Font.Bold

    FontLoader {
        id: materialFont
        source: "../assets/MaterialSymbolsRounded.ttf"
    }

    text: icon
    color: iconColor

    renderType: Text.NativeRendering
    renderTypeQuality: Text.VeryHighRenderTypeQuality

    font {
        family: materialFont.name
        pixelSize: size
        variableAxes: {
            "wght": weight,
            "FILL": 1,
            "GRAD": 200,
            "opsz": 20
        }
    }
}
