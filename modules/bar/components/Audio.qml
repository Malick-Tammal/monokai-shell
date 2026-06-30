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

    MouseArea {
        id: audioMouseArea
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
        width: row.implicitWidth + 20
        radius: 10
        color: ColorEngine.monokai_fusion.blue2

        Item {
            id: fillSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: soundPer
                height: parent.height
                width: parent.width * Audio.volume
                color: audioMouseArea.containsMouse ? ColorEngine.monokai_fusion.blue4 : ColorEngine.monokai_fusion.blue5

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
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

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6
            z: 1

            Symbols {
                icon: Audio.symbol
                size: Style.symbolSize
                iconColor: ColorEngine.monokai_fusion.blue9
            }

            Sliding {
                text: Math.round(Audio.volume * 100)
                textColor: ColorEngine.monokai_fusion.blue9
                size: Style.fontSizeMd
                weight: Font.Bold
                styleName: "Bold"
                fastAnimation: true

                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0.5
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: ColorEngine.monokai_fusion.blue2
            border.width: 1
            radius: con.radius
            z: 2
        }
    }
}
