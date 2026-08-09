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
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
    }

    Rectangle {
        id: con
        height: parent.height
        width: row.implicitWidth + 20
        radius: 10
        color: Battery.isPluggedIn ? Style.successBorder : (Battery.percentage <= 0.15 ? Style.errorBorder : Style.notifyBorder)

        Item {
            id: fillSource
            anchors.fill: parent
            visible: false

            Rectangle {
                id: batteryPer
                height: parent.height
                width: parent.width * Battery.percentage

                color: {
                    if (Battery.isPluggedIn) {
                        return hoverHandler.hovered ? Style.successHover : Style.success;
                    }
                    if (Battery.percentage <= 0.15) {
                        return hoverHandler.hovered ? Style.errorHover : Style.error;
                    }
                    return hoverHandler.hovered ? Style.notifyHover : Style.notify;
                }

                SequentialAnimation on x {
                    running: Battery.percentage <= 0.15 && !Battery.isPluggedIn
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
                    running: Battery.isPluggedIn
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

                onOpacityChanged: if (!Battery.isPluggedIn)
                    opacity = 1.0

                onXChanged: if (Math.round(Battery.percentage) >= 0.15 || Battery.isPluggedIn)
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
            height: parent.height
            spacing: 6
            z: 1
            clip: true

            Symbols {
                id: batteryIcon
                y: Math.round((parent.height - height) / 2)
                size: Style.symbolSize

                color: {
                    if (Battery.isPluggedIn)
                        return Style.textOnSuccess;
                    if (Battery.percentage <= 0.15)
                        return Style.textOnError;
                    return Style.textOnNotify;
                }

                icon: "battery_android_full"

                state: {
                    if (Battery.isPluggedIn)
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
                            properties: "icon,color"
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
                color: {
                    if (Battery.isPluggedIn)
                        return Style.textOnSuccess;
                    if (Battery.percentage <= 0.15)
                        return Style.textOnError;
                    return Style.textOnNotify;
                }
                renderType: Text.NativeRendering
                renderTypeQuality: Text.VeryHighRenderTypeQuality

                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0.5

                font {
                    family: Style.family
                    weight: Font.Black
                    pixelSize: Style.fontSizeMd
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: {
                if (Battery.isPluggedIn) {
                    return Style.successBorder;
                }
                if (Battery.percentage <= 0.15) {
                    return Style.errorBorder;
                }
                return Style.notifyBorder;
            }
            border.width: 1
            radius: con.radius
            z: 2
        }
    }
}
