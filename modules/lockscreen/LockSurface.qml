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
    color: Style.background

    // Rounded corners
    Corners {
        anchors.fill: parent
        rounding: 45
        z: 99
    }

    // Background
    Image {
        id: background
        anchors.fill: parent
        source: WalliService.currentWallPath
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: parent.width > 0 ? parent.width : 1920
        sourceSize.height: parent.height > 0 ? parent.height : 1080
        visible : false
        z: 0
    }

    MultiEffect {
        source: background
        anchors.fill: parent
        blurEnabled: true
        autoPaddingEnabled: false
        blur: 0.85
        blurMax: 64
        blurMultiplier: 0.15
        brightness: -0.05
    }

    // Border with rounded corners
    Rectangle {
        id: border
        anchors.fill: parent
        color: "transparent"
        border.width: root.borderWidth
        border.color: Style.background
        z: 10
    }

    Item {
        id: corners
        anchors.fill: parent
        enabled: false
        z: 10

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

            delegate: InvertedCorner {
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
                rounding: 30
                roundingColor: Style.background
            }
        }
    }

    Clock {
        id: clock
        z: 3

        anchors {
            centerIn: parent
            verticalCenterOffset: passwordInput.rowVisible ? -100 : 0
        }

        Behavior on anchors.verticalCenterOffset {
            SpringAnimation {
                spring: 10
                damping: 0.4
                mass: 1.8
            }
        }
    }

    PasswordInput {
        id: passwordInput
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.borderWidth
        z:4
    }

    //  INFO: Handy for testing
    // Rectangle {
    //     width: text.width + 20
    //     height: 50
    //     z: 2
    //     color: ColorEngine.monokai_fusion.dark5
    //     radius: 20
    //
    //     Text {
    //         id: text
    //         text: "Its not working, let me out"
    //         anchors.centerIn: parent
    //         color: ColorEngine.monokai_fusion.dark1
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
