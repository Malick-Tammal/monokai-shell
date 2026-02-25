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
        color: Style.black
        opacity: root.isActive ? 0.3 : 0
        anchors.centerIn: parent
        radius: 15

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
        color: Style.bg
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
                color: Style.fg
                anchors.horizontalCenter: parent.horizontalCenter

                font {
                    family: Style.family
                    weight: Font.Bold
                    pixelSize: Style.fontSizeMd
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                Rectangle {
                    id: yes
                    width: yesTxt.width + 60
                    height: yesTxt.height + 15

                    property Item nextItem: no
                    property Item prevItem: no

                    color: (activeFocus || yesMouseArea.containsMouse) ? Style.green5 : Style.gray6
                    border.color: activeFocus ? Style.green2 : Style.gray4
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
                        color: (yes.activeFocus || yesMouseArea.containsMouse) ? Style.green9 : Style.fg
                        anchors.centerIn: parent

                        font {
                            family: Style.family
                            weight: Font.DemiBold
                            pixelSize: Style.fontSizeMd
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
                    width: noTxt.width + 60
                    height: noTxt.height + 15

                    property Item nextItem: yes
                    property Item prevItem: yes

                    color: (activeFocus || noMouseArea.containsMouse) ? Style.red5 : Style.gray6
                    border.color: activeFocus ? Style.red3 : Style.gray4
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
                        color: (no.activeFocus || noMouseArea.containsMouse) ? Style.green9 : Style.fg
                        anchors.centerIn: parent

                        font {
                            family: Style.family
                            weight: Font.DemiBold
                            pixelSize: Style.fontSizeMd
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
