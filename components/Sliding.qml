import QtQuick
import qs.theme

Item {
    id: root
    width: row.width
    height: row.height
    clip: true

    property string text: "00"
    property color color: Style.fg
    property int orientation: Qt.Vertical
    property int size: 17
    property int weight: Font.Black

    Row {
        id: row
        spacing: 0

        Repeater {
            model: root.text.length

            delegate: Item {
                id: charItem
                width: charText.width
                height: charText.height
                clip: true

                property string targetChar: root.text.charAt(index)
                property string _displayChar: targetChar
                property real _offset: 0

                onTargetCharChanged: {
                    if (targetChar !== _displayChar) {
                        anim.restart();
                    }
                }

                Text {
                    id: charText
                    text: charItem._displayChar
                    color: root.color
                    renderType: Text.NativeRendering

                    transform: Translate {
                        x: root.orientation === Qt.Horizontal ? charItem._offset : 0
                        y: root.orientation === Qt.Vertical ? charItem._offset : 0
                    }

                    font {
                        pixelSize: root.size
                        family: Style.family
                        weight: root.weight
                    }
                }

                SequentialAnimation {
                    id: anim

                    ParallelAnimation {
                        NumberAnimation {
                            target: charItem
                            property: "_offset"
                            to: -40
                            duration: 250
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            target: charText
                            property: "opacity"
                            to: 0
                            duration: 150
                        }
                    }

                    ScriptAction {
                        script: charItem._displayChar = charItem.targetChar
                    }

                    PropertyAction {
                        target: charItem
                        property: "_offset"
                        value: 20
                    }

                    ParallelAnimation {
                        NumberAnimation {
                            target: charItem
                            property: "_offset"
                            to: 0
                            duration: 350
                            easing.type: Easing.OutBack
                        }
                        NumberAnimation {
                            target: charText
                            property: "opacity"
                            to: 1
                            duration: 250
                        }
                    }
                }
            }
        }
    }
}