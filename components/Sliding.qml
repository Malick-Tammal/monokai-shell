import QtQuick
import qs.theme

Item {
    id: root
    width: mainText.width + 5
    height: mainText.height
    clip: true

    property string text: "00"
    property color color: Style.fg
    property int orientation: Qt.Vertical
    property int size: 17

    property string _displayText: "00"
    property real _offset: 0

    onTextChanged: {
        if (text !== _displayText) {
            anim.restart();
        }
    }

    Text {
        id: mainText
        text: root._displayText
        color: root.color
        anchors.centerIn: parent
        renderType: Text.NativeRendering

        transform: Translate {
            id: textTransform
            x: root.orientation === Qt.Horizontal ? root._offset : 0
            y: root.orientation === Qt.Vertical ? root._offset : 0
        }

        font {
            pixelSize: root.size
            family: Style.family
            weight: Font.Black
        }
    }

    SequentialAnimation {
        id: anim

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "_offset"
                to: -40
                duration: 250
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: mainText
                property: "opacity"
                to: 0
                duration: 150
            }
        }

        ScriptAction {
            script: root._displayText = root.text
        }

        PropertyAction {
            target: root
            property: "_offset"
            value: 20
        }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "_offset"
                to: 0
                duration: 350
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: mainText
                property: "opacity"
                to: 1
                duration: 250
            }
        }
    }
}
