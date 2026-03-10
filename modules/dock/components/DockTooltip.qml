import QtQuick
import qs.theme

Rectangle {
    id: tooltip

    required property string text
    required property bool show

    color: Style.bg
    border.color: Style.border
    border.width: 1
    radius: 8
    width: tooltipText.implicitWidth + 16
    height: tooltipText.implicitHeight + 10
    anchors.horizontalCenter: parent.horizontalCenter
    y: -height - 5

    opacity: show ? 1.0 : 0.0
    scale: show ? 1.0 : 0.6

    transformOrigin: Item.Bottom

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    Text {
        id: tooltipText
        text: tooltip.text
        color: Style.fg
        font.pixelSize: Style.fontSizeSm
        font.family: Style.family
        anchors.centerIn: parent
    }
}
