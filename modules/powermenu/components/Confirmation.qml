import QtQuick
import qs.theme
import QtQuick.Layouts
import qs.components

Item {
    id: root
    anchors.fill: parent
    z: 10
    clip: true

    signal confirm
    signal cancel

    property bool isActive: false
    visible: isActive || slideAnim.running || fadeAnim.running

    onVisibleChanged: {
        if (visible) {
            yes.forceActiveFocus();
        }
    }

    Rectangle {
        id: overlay
        width: parent.width - 2
        height: parent.height - 2
        color: ColorEngine.monokai_fusion.black
        opacity: root.isActive ? 0.5 : 0
        anchors.centerIn: parent
        radius: 15
        antialiasing: true

        Behavior on opacity {
            NumberAnimation {
                id: fadeAnim
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.cancel()
        }
    }

    Rectangle {
        id: window
        width: row.implicitWidth + 20
        height: row.implicitHeight + 20
        anchors.centerIn: parent
        color: Style.background
        radius: 15
        border.color: Style.border

        transform: Translate {
            y: root.isActive ? 0 : root.height

            Behavior on y {
                NumberAnimation {
                    id: slideAnim
                    duration: 200
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.8
                }
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        RowLayout {
            id: row
            spacing: 20
            anchors.centerIn: parent

            Text {
                text: "Are you sure?"
                color: Style.primary
                leftPadding: 10

                font {
                    family: Style.family
                    weight: Font.DemiBold
                    pixelSize: Style.fontSizeXl
                    styleName: "SemiBold"
                }
            }

            Row {
                spacing: 10

                Rectangle {
                    id: yes

                    property Item nextItem: no
                    property Item prevItem: no

                    height: 70
                    width: 70
                    radius: 10
                    color: (activeFocus || yesMouseArea.containsMouse) ? Style.success : ColorEngine.monokai_fusion.gray6
                    border.color: activeFocus ? Style.successBorder : Style.borderDim
                    focus: true

                    Symbols {
                        icon: "check"
                        iconColor: (yes.activeFocus || yesMouseArea.containsMouse) ? Style.onSuccess : Style.textSecondary
                        anchors.centerIn: parent
                        size: 30
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Keys.onPressed: event => {
                        if (event.text === "h" || event.key === Qt.Key_Left) {
                            if (prevItem) {
                                prevItem.forceActiveFocus();
                                event.accepted = true;
                            }
                        } else if (event.text === "l" || event.key === Qt.Key_Right) {
                            if (nextItem) {
                                nextItem.forceActiveFocus();
                                event.accepted = true;
                            }
                        } else if (event.text === "k" || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.confirm();
                            event.accepted = true;
                        }
                    }

                    MouseArea {
                        id: yesMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            yes.forceActiveFocus();
                            root.confirm();
                        }
                    }

                }

                Rectangle {
                    id: no

                    property Item nextItem: yes
                    property Item prevItem: yes

                    height: 70
                    width: 70
                    radius: 10
                    color: (activeFocus || noMouseArea.containsMouse) ? Style.error : ColorEngine.monokai_fusion.gray6
                    border.color: activeFocus ? Style.errorBorder : Style.borderDim
                    focus: true

                    Symbols {
                        icon: "close"
                        iconColor: (no.activeFocus || noMouseArea.containsMouse) ? Style.onError : Style.textSecondary
                        anchors.centerIn: parent
                        size: 30
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Keys.onPressed: event => {
                        if (event.text === "h" || event.key === Qt.Key_Left) {
                            if (prevItem) {
                                prevItem.forceActiveFocus();
                                event.accepted = true;
                            }
                        } else if (event.text === "l" || event.key === Qt.Key_Right) {
                            if (nextItem) {
                                nextItem.forceActiveFocus();
                                event.accepted = true;
                            }
                        } else if (event.text === "k" || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.cancel();
                            event.accepted = true;
                        }
                    }

                    MouseArea {
                        id: noMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            no.forceActiveFocus();
                            root.cancel();
                        }
                    }

                }
            }
        }
    }
}
