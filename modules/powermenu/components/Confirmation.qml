import QtQuick
import qs.theme

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
        width: parent.width / 2
        height: parent.height / 1.3
        anchors.centerIn: parent
        color: Style.background
        radius: 15
        border.color: Style.border

        transform: Translate {
            y: root.isActive ? 0 : root.height

            Behavior on y {
                NumberAnimation {
                    id: slideAnim
                    duration: 150
                    easing.type: Easing.OutQuart
                }
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        Column {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 20

            Text {
                text: "Are you sure?"
                color: Style.textPrimary
                anchors.horizontalCenter: parent.horizontalCenter

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeLg
                    styleName: "Bold"
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                Rectangle {
                    id: yes
                    width: noTxt.width + 80
                    height: noTxt.height + 20

                    property Item nextItem: no
                    property Item prevItem: no

                    color: (activeFocus || yesMouseArea.containsMouse) ? Style.success : ColorEngine.monokai_fusion.gray6
                    border.color: activeFocus ? Style.successBorder : Style.borderDim
                    radius: 10
                    focus: true

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

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Text {
                        id: yesTxt
                        text: "Yes"
                        color: (yes.activeFocus || yesMouseArea.containsMouse) ? Style.onSuccess : Style.textPrimary
                        anchors.centerIn: parent

                        font {
                            family: Style.family
                            weight: Font.DemiBold
                            pixelSize: Style.fontSizeMd
                            styleName: "DemiBold"
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
                    width: noTxt.width + 80
                    height: noTxt.height + 20

                    property Item nextItem: yes
                    property Item prevItem: yes

                    color: (activeFocus || noMouseArea.containsMouse) ? Style.error : ColorEngine.monokai_fusion.gray6
                    border.color: activeFocus ? Style.errorBorder : Style.borderDim
                    radius: 10
                    focus: true

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

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }

                    Text {
                        id: noTxt
                        text: "No"
                        color: (no.activeFocus || noMouseArea.containsMouse) ? Style.onSuccess : Style.textPrimary
                        anchors.centerIn: parent

                        font {
                            family: Style.family
                            weight: Font.DemiBold
                            pixelSize: Style.fontSizeMd
                            styleName: "DemiBold"
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
