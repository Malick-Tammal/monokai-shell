import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.theme
import qs.components
import qs.services
import "./components/"

Rectangle {
    id : root

    required property var context
    property int borderWidth: 20
    color: Style.dark5

    anchors {
        fill: parent
    }

    Image {
        id: background
        anchors.fill: parent
        source: Pywal.wallpaper
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: parent.width > 0 ? parent.width : 1920
        sourceSize.height: parent.height > 0 ? parent.height : 1080
        visible : true
        z: 0
    }

    MultiEffect {
        source: background
        anchors.fill: background
        blurEnabled: true
        autoPaddingEnabled: false
        blur: 0.85
        blurMax: 64
        blurMultiplier: 0.15
        brightness: -0.12
    }

    Rectangle {
        id: border
        anchors.fill: parent
        color: "transparent"
        border.width: root.borderWidth
        border.color: Style.dark5
        z:4
    }

    Item {
        id: cornors
        anchors.fill: parent
        enabled: false
        z: 5

        Repeater {
            model: [
            // Top right
            {
                anchorTop: true,
                anchorRight: true,
                rot: 0,
                x: -root.borderWidth,
                y: root.borderWidth,
            },

            // Top left
            {
                anchorTop: true,
                anchorLeft: true,
                rot: -90,
                x: root.borderWidth,
                y: root.borderWidth,
            },

            // Bottom right
            {
                anchorBottom: true,
                anchorRight: true,
                rot: 90,
                x: -root.borderWidth,
                y: -root.borderWidth,
            },

            // Bottom left
            {
                anchorBottom: true,
                anchorLeft: true,
                rot: -180,
                x: root.borderWidth,
                y: -root.borderWidth,
            }
            ]

            delegate: InvertedCornor {
                anchors {
                    top: modelData.anchorTop ? parent.top : undefined
                    bottom: modelData.anchorBottom ? parent.bottom : undefined
                    left: modelData.anchorLeft ? parent.left : undefined
                    right: modelData.anchorRight ? parent.right : undefined
                }

                transform: Translate {
                    x: modelData.x
                    y: modelData.y
                }

                rotation: modelData.rot
                rounding : 30
                roundingColor : Style.dark5
            }
        }
    }

    Clock {
        id: clock
        anchors.centerIn: parent
        transform: Translate {
            y: passwordInput.rowVisible ? -100 : 0
            Behavior on y {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                    easing.overshoot: 0
                }
            }
        }
    }

    PasswordInput {
        id: passwordInput
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.borderWidth
        z:3
    }

    Cornors {
        anchors.fill: parent
        rounding: 45
        z: 99
    }

    //  INFO: Handy for testing
    // Rectangle {
    //     width: text.width + 20
    //     height: 50
    //     z: 2
    //     color: Style.dark5
    //     radius: 20
    //
    //     Text {
    //         id: text
    //         text: "Its not working, let me out"
    //         anchors.centerIn: parent
    //         color: Style.dark1
    //     }
    //
    //     MouseArea {
    //         anchors.fill: parent
    //         cursorShape: Qt.CursorShape.PointingHandCursor
    //         onClicked: root.context.locked = false;
    //     }
    //
    //     anchors {
    //         right : parent.right
    //         bottom : parent.bottom
    //         rightMargin: 40
    //         bottomMargin: 40
    //     }
    // }
}
