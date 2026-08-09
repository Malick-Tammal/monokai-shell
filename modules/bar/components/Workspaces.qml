import QtQuick
import qs.theme
import qs.services
import qs.components
import Quickshell.Hyprland

Item {
    id: root
    width: row.childrenRect.width + row.anchors.leftMargin + row.anchors.rightMargin
    height: parent.height

    Rectangle {
        id: workspaces
        radius: 9999
        antialiasing: true
        color: Style.background
        border.color: Style.border
        anchors.fill: parent

        Row {
            id: row
            spacing: 10

            anchors {
                fill: parent
                topMargin: 8
                bottomMargin: 8
                leftMargin: (Hypr.focusedWorkspaceId === 1) ? 8 : 12
                rightMargin: (Hypr.focusedWorkspaceId === Hypr.lastVisibleWs) ? 8 : 12
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
                    property bool isFocused: Hypr.focusedWorkspaceId === wsId
                    property bool hasWindows: Hypr.hasWindows(wsId)
                    property bool isUrgent: Hypr.isUrgent(wsId)
                    property double lastUrgentTime: 0

                    onIsUrgentChanged: {
                        if (isUrgent) {
                            lastUrgentTime = Date.now();
                        } else {
                            lastUrgentTime = 0;
                        }
                    }

                    Connections {
                        target: Hypr
                        function onUrgentPulse(id) {
                            if (id === wsId) {
                                let elapsed = Date.now() - lastUrgentTime;

                                if (isUrgent && elapsed > 200) {
                                    flashAnim.restart();
                                }
                            }
                        }
                    }

                    SequentialAnimation {
                        id: flashAnim
                        NumberAnimation {
                            target: ws
                            property: "opacity"
                            to: 0.3
                            duration: 120
                        }
                        NumberAnimation {
                            target: ws
                            property: "opacity"
                            to: 1.0
                            duration: 120
                        }
                        NumberAnimation {
                            target: ws
                            property: "opacity"
                            to: 0.3
                            duration: 120
                        }
                        NumberAnimation {
                            target: ws
                            property: "opacity"
                            to: 1.0
                            duration: 120
                        }
                    }

                    HoverHandler {
                        id: hoverHandler
                    }

                    visible: wsId <= 7 || hasWindows || isFocused

                    height: visible ? (isFocused ? parent.height : 20) : 0
                    width: visible ? (isFocused ? 110 : 34) : 0
                    radius: 9999
                    antialiasing: true

                    anchors.verticalCenter: parent.verticalCenter

                    color: {
                        if (isUrgent) {
                            return Style.warning;
                        }

                        if (isFocused) {
                            if (hoverHandler.hovered) {
                                return Style.successHover;
                            } else {
                                return Style.success;
                            }
                        }

                        if (hoverHandler.hovered) {
                            return Style.indicatorIdle;
                        } else {
                            return Style.inactive;
                        }
                    }

                    border.color: {
                        if (isUrgent) {
                            return Style.warningLight;
                        }

                        if (isFocused) {
                            return Style.successMuted;
                        } else {
                            return Style.inactiveBorder;
                        }
                    }

                    border.width: isFocused ? 5 : 1

                    clip: true

                    Text {
                        text: wsId
                        visible: !isFocused
                        color: {
                            if (isUrgent) {
                                return Style.textOnWarning;
                            }
                            if (hasWindows) {
                                return Style.textPrimary;
                            } else {
                                return Style.textDisabled;
                            }
                        }
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
                            weight: Font.Bold
                            styleName: "Bold"
                        }
                    }

                    Icons {
                        path: "../../../assets/icons/star.svg"
                        size: 12

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
                        onClicked: Hypr.focusWorkspace(wsId)
                    }
                }
            }
        }
    }
}
