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

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CursorShape.PointingHandCursor
        hoverEnabled: true
    }

    Rectangle {
        id: con
        height: parent.height
        width: row.width + 18
        radius: 10
        color: Battery.acConnected ? Style.green2 : (Battery.percentage <= 0.15 ? Style.red2 : Style.orange2)

        Item {
            id: fillSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: batteryPer
                height: parent.height
                width: parent.width * Battery.percentage

                color: {
                    if (Battery.acConnected) {
                        return hoverHandler.hovered ? Style.green4 : Style.green5;
                    }
                    if (Battery.percentage <= 0.15) {
                        return hoverHandler.hovered ? Style.red4 : Style.red5;
                    }
                    return hoverHandler.hovered ? Style.orange4 : Style.orange5;
                }

                SequentialAnimation on x {
                    running: Battery.percentage <= 0.15 && !Battery.acConnected
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 1
                        duration: 50
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        to: -1
                        duration: 50
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        to: 0
                        duration: 50
                        easing.type: Easing.InOutQuad
                    }
                    PauseAnimation {
                        duration: 2000
                    }
                }

                SequentialAnimation on opacity {
                    running: Battery.acConnected
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: 0.7
                        duration: 1000
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: 1.0
                        duration: 1000
                        easing.type: Easing.InOutSine
                    }
                }

                onOpacityChanged: if (!Battery.acConnected)
                    opacity = 1.0

                onXChanged: if (Math.round(Battery.percentage) >= 0.15 || Battery.acConnected)
                    x = 0

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.OutExpo
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
            spacing: 5
            z: 1
            clip: true

            Symbols {
                id: batteryIcon
                anchors.verticalCenter: parent.verticalCenter
                size: Battery.acConnected ? 13 : 14

                iconColor: {
                    if (Battery.acConnected)
                        return Style.green9;
                    if (Battery.percentage <= 0.15)
                        return Style.red9;
                    return Style.orange9;
                }

                icon: "battery_android_full"

                state: {
                    if (Battery.acConnected)
                        return "charging";
                    if (Battery.percentage <= 0.15)
                        return "low";
                    return "discharging";
                }

                states: [
                    State {
                        name: "charging"
                        PropertyChanges {
                            target: batteryIcon
                            icon: "electric_bolt"
                        }
                    },
                    State {
                        name: "discharging"
                        PropertyChanges {
                            target: batteryIcon
                            icon: "battery_android_full"
                        }
                    },
                    State {
                        name: "low"
                        PropertyChanges {
                            target: batteryIcon
                            icon: "warning"
                        }
                    }
                ]

                transitions: Transition {
                    from: "*"
                    to: "*"

                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: batteryIcon
                                property: "x"
                                to: 20
                                duration: 150
                                easing.type: Easing.InQuad
                            }
                            NumberAnimation {
                                target: batteryIcon
                                property: "opacity"
                                to: 0
                                duration: 150
                            }
                        }

                        PropertyAction {
                            target: batteryIcon
                            properties: "icon,iconColor"
                        }

                        PropertyAction {
                            target: batteryIcon
                            property: "x"
                            value: -20
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: batteryIcon
                                property: "x"
                                to: 0
                                duration: 250
                                easing.type: Easing.OutBack
                            }
                            NumberAnimation {
                                target: batteryIcon
                                property: "opacity"
                                to: 1
                                duration: 200
                            }
                        }
                    }
                }
            }

            Text {
                text: Math.round(Battery.percentage * 100)
                anchors.verticalCenter: parent.verticalCenter
                color: {
                    if (Battery.acConnected)
                        return Style.green9;
                    if (Battery.percentage <= 0.15)
                        return Style.red9;
                    return Style.orange9;
                }
                renderType: Text.NativeRendering
                anchors.verticalCenterOffset: 0.5

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeSm
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Battery.acConnected ? Style.green2 : (Battery.percentage <= 0.15 ? Style.red2 : Style.orange2)
            border.width: 1
            radius: con.radius
            z: 2
        }
    }
}
