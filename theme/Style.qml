pragma Singleton
import QtQuick

QtObject {
    property color bg: ColorEngine.monokai_fusion.dark5
    property color fg: ColorEngine.monokai_fusion.white
    property color border: ColorEngine.monokai_fusion.yellow5

    property int fontSizeXs: 10
    property int fontSizeSm: 12
    property int fontSizeMd: 14
    property int fontSizeLg: 18
    property int fontSizeXl: 20
    property int fontSize2Xl: 25
    property int fontSize3Xl: 50

    property string family: "SF Pro Rounded"
    property string nerdFamily: "JetBrains Nerd Font"

    property int symbolSize: 15
    property int globalPadding: 10
}
