import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../theme/"
import "../../../components/"

Item {
    width: row.childrenRect.width + (row.anchors.margins * 2)
    height: parent.height

    Rectangle {
        id: workspaces
        radius: 9999
        color: Style.bg
        border.color: Style.border
        anchors.fill: parent

        Row {
            id: row
            anchors.fill: parent

            anchors.margins: 8

            spacing: 10

            Repeater {
                model: 10

                Rectangle {
                    id: ws

                    property int wsId: index + 1
                    property bool isFocused: (Hyprland.focusedWorkspace?.id === index + 1) ?? false
                    property bool hasWindows: Hyprland.workspaces.values.some(w => w.id === index + 1)

                    HoverHandler {
                        id: hoverHandler
                    }

                    visible: wsId <= 7 || hasWindows || isFocused

                    height: visible ? (isFocused ? parent.height : 20) : 0
                    width: visible ? (isFocused ? 90 : 40) : 0
                    radius: 9999

                    anchors.verticalCenter: parent.verticalCenter

                    color: isFocused ? (hoverHandler.hovered ? Style.green4 : Style.green5) : (hoverHandler.hovered ? Style.gray5 : Style.gray6)
                    border.color: isFocused ? Style.green7 : Style.dark1
                    border.width: isFocused ? 4 : 1

                    clip: true

                    Text {
                        text: wsId
                        visible: !isFocused
                        anchors.centerIn: parent
                        color: hasWindows ? Style.fg : Style.gray3
                        renderType: Text.NativeRendering
                        anchors.verticalCenterOffset: 1.2

                        font {
                            family: Style.family
                            pixelSize: Style.fontSizeSm
                            weight: Font.Medium
                        }
                    }

                    Icon {
                        path: "../../../assets/icons/star.svg"
                        size: 10

                        x: Math.round((parent.width - width) / 2)
                        y: Math.round((parent.height - height) / 2)

                        visible: ws.isFocused

                        rotation: parent.isFocused ? 0 : 180

                        Behavior on rotation {
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: 150
                                }
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.BezierSpline
                                }
                            }
                        }

                        scale: parent.isFocused ? 1 : 1.3

                        Behavior on scale {
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: 350
                                }
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutBounce
                                }
                            }
                        }
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.Bezier
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.CursorShape.PointingHandCursor
                        hoverEnabled: true
                        onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    }
                }
            }
        }
    }
}
