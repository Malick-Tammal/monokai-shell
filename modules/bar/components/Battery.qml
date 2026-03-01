import QtQuick
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

    Rectangle {
        id: con
        height: parent.height
        width: row.width + 18
        radius: 10
        color: Battery.acConnected ? Style.green2 : Style.orange2

        Item {
            id: fillSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: batteryPer
                height: parent.height
                width: parent.width * Battery.percentage
                color: Battery.acConnected ? (hoverHandler.hovered ? Style.green4 : Style.green5) : (hoverHandler.hovered ? Style.orange4 : Style.orange5)

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
            border.color: Battery.acConnected ? Style.green2 : Style.orange2
            border.width: 1
            radius: con.radius
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 5

            Symbols {
                icon: "battery_android_full"
                size: 14
                iconColor: Style.orange9
                visible: !Battery.acConnected

                transform: Translate {
                    x: !Battery.acConnected ? 0 : -parent.width

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Icons {
                path: "../../../assets/icons/zap.svg"
                size: 13
                visible: Battery.acConnected
                anchors.verticalCenter: parent.verticalCenter

                transform: Translate {
                    x: Battery.acConnected ? 0 : -parent.width

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            Text {
                text: Math.round(Battery.percentage * 100)
                anchors.verticalCenter: parent.verticalCenter
                color: Battery.acConnected ? Style.green9 : Style.orange9
                renderType: Text.NativeRendering

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeSm
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CursorShape.PointingHandCursor
            hoverEnabled: true
        }
    }
}
