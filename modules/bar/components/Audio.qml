import QtQuick
import Quickshell
import qs.theme
import qs.services
import qs.components
import Qt5Compat.GraphicalEffects

Item {
    id: root
    height: parent.height
    width: con.width

    HoverHandler {
        id: hoverHandler
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CursorShape.PointingHandCursor
        hoverEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                Audio.decrementVolume(0.01);
            } else if (wheel.angleDelta.y < 0) {
                Audio.incrementVolume(0.01);
            }
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                Audio.toggleMute();
                return;
            }
            if (mouse.button === Qt.LeftButton) {
                Quickshell.execDetached(["pavucontrol"]);
                return;
            }
        }
    }

    Rectangle {
        id: con
        height: parent.height
        width: row.width + 18
        radius: 10
        color: Style.blue2

        Item {
            id: fillSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: soundPer
                height: parent.height
                width: parent.width * Audio.volume
                color: Style.blue5

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
        }

        OpacityMask {
            anchors.fill: con
            source: fillSource
            maskSource: Rectangle {
                width: con.width
                height: con.height
                radius: con.radius
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Style.blue2
            border.width: 1
            radius: con.radius
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 5

            Symbols {
                icon: Audio.symbol
                size: 14
                iconColor: Style.blue9
            }

            Text {
                text: Math.round(Audio.volume * 100)
                anchors.verticalCenter: parent.verticalCenter
                color: Style.blue9
                renderType: Text.NativeRendering

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeSm
                }
            }
        }
    }
}
