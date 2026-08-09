import QtQuick
import qs.theme

Text {
    id: root

    required property string icon
    property int size: Style.symbolSize2Xl
    property int weight: 600
    property bool filled: true

    FontLoader {
        id: filledRegular
        source: "../assets/static/MaterialSymbolsRounded_Filled-Regular.ttf"
    }

    FontLoader {
        id: filledBold
        source: "../assets/static/MaterialSymbolsRounded_Filled-Bold.ttf"
    }

    FontLoader {
        id: outlinedRegular
        source: "../assets/static/MaterialSymbolsRounded_36pt-Regular.ttf"
    }

    FontLoader {
        id: outlinedBold
        source: "../assets/static/MaterialSymbolsRounded_36pt-Bold.ttf"
    }

    text: icon

    renderType: Text.QtRendering
    renderTypeQuality: Text.VeryHighRenderTypeQuality

    font {
        family: {
            if (!root.filled) {
                return root.weight >= 600 ? outlinedBold.name : outlinedRegular.name;
            } else {
                return root.weight >= 600 ? filledBold.name : filledRegular.name;
            }
        }

        pixelSize: root.size
        weight: root.weight
        styleName: root.weight
        variableAxes: {
            "FILL": root.filled ? 0 : 0,
            "wght": root.weight,
            "GRAD": 200,
            "opsz": root.size
        }
    }
}
