import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.theme
import "../../../components/"

Item {
    id: root
    width: row.childrenRect.width + row.anchors.leftMargin + row.anchors.rightMargin
    height: parent.height

    Rectangle {
        id: workspaces
        radius: 9999
        color: Style.bg
        border.color: Style.border
        anchors.fill: parent

        Row {
            id: row
            spacing: 8

            property int lastVisibleWs: {
                let maxId = 7;
                let activeId = Hyprland.focusedWorkspace?.id || 0;

                if (activeId > maxId && activeId <= 10) {
                    maxId = activeId;
                }

                let wsArray = Hyprland.workspaces.values;
                for (let i = 0; i < wsArray.length; ++i) {
                    if (wsArray[i].id > maxId && wsArray[i].id <= 10) {
                        maxId = wsArray[i].id;
                    }
                }
                return maxId;
            }

            anchors {
                fill: parent
                topMargin: 8
                bottomMargin: 8
                leftMargin: (Hyprland.focusedWorkspace?.id === 1) ? 8 : 10
                rightMargin: (Hyprland.focusedWorkspace?.id === lastVisibleWs) ? 8 : 10
            }

            Behavior on anchors.leftMargin {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutExpo
                }
            }

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutExpo
                }
            }

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
                    width: visible ? (isFocused ? 90 : 34) : 0
                    radius: 9999

                    anchors.verticalCenter: parent.verticalCenter

                    color: isFocused ? (hoverHandler.hovered ? Style.green4 : Style.green5) : (hoverHandler.hovered ? Style.gray5 : Style.gray6)
                    border.color: isFocused ? Style.green7 : Style.dark1
                    border.width: isFocused ? 4 : 1

                    clip: true

                    Text {
                        text: wsId
                        visible: !isFocused
                        color: hasWindows ? Style.fg : Style.gray3
                        renderType: Text.NativeRendering
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        anchors {
                            centerIn: parent
                            verticalCenterOffset: 1.2
                        }

                        font {
                            family: Style.family
                            pixelSize: Style.fontSizeSm
                            weight: Font.Medium
                        }
                    }

                    Icons {
                        path: "../../../assets/icons/star.svg"
                        size: 10

                        x: Math.round((parent.width - width) / 2)
                        y: Math.round((parent.height - height) / 2)

                        visible: ws.isFocused

                        rotation: parent.isFocused ? 0 : -180

                        Behavior on rotation {
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: 100
                                }
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.OutExpo
                                }
                            }
                        }

                        scale: parent.isFocused ? 1 : 1.3

                        Behavior on scale {
                            SequentialAnimation {
                                PauseAnimation {
                                    duration: 300
                                }
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 2
                                }
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.OutQuad
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.OutQuad
                        }
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
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
