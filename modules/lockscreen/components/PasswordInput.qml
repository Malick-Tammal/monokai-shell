import QtQuick
import Quickshell
import qs.theme
import qs.components
import qs.services

Item {
    id: root
    height: row.height
    width: row.width

    property bool rowVisible: false
    property int borderSize: 5

    function clearAndHide() {
        passwordInput.text = ""
        rowVisible = false
        hideTimer.stop()
        resetUI()
    }

    ListModel { id: passwordChars }

    Timer {
        id: hideTimer
        interval: 10000
        repeat: false
        onTriggered: root.clearAndHide()
    }

    Timer {
        id: resetFailed
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            if (LockScreenService.showFailure) {
                passwordStatus.text = "Type your password..."
                resetUI()
            }
        }
    }

    function resetUI() {
        passwordInput.readOnly = false
        passwordStatus.text = "Type your password..."
        passwordStatus.color = Style.textMuted
        passwordContainer.border.color = Style.surfaceDim
        passwordContainerMask.border.color = Style.surfaceDim
        passwordContainer.color = Style.surface
    }

    function updateUIState() {
        if (LockScreenService.unlockInProgress) {
            passwordInput.readOnly = true
            passwordStatus.text = "Unlocking..."
            passwordStatus.color = Style.warning
            passwordContainer.border.color = Style.warning
            passwordContainerMask.border.color = Style.warning
            passwordContainer.color = Style.warningContainer

        } else if (LockScreenService.showFailure) {
            passwordInput.readOnly = false
            passwordStatus.text = "Wrong password"
            passwordStatus.color = Style.error
            passwordStatus.color = Style.error
            passwordContainer.border.color = Style.error
            passwordContainerMask.border.color = Style.error
            passwordContainer.color = Style.errorContainer
            resetFailed.start()
        } else {
            resetUI()
        }
    }

    Connections {
        target: LockScreenService

        function onUnlockInProgressChanged() {
            if (LockScreenService.unlockInProgress) passwordInput.text = ""
            updateUIState()
        }

        function onShowFailureChanged() {
            if (LockScreenService.showFailure) {
                passwordInput.text = ""
                LockScreenService.currentText = ""
                shakeAnimation.start()
            }
            updateUIState()
        }
    }

    Component.onCompleted: passwordInput.forceActiveFocus()

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: passwordInput.forceActiveFocus()
    }

    Row {
        id: row

        transform: Translate {
            id: rowTransform
            y: root.rowVisible ? 0 : row.height + 12
            Behavior on y {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                    easing.overshoot: 1.4
                }
            }
        }

        SequentialAnimation {
            id: shakeAnimation

            NumberAnimation { target: rowTransform; property: "x"; to: -20; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 2 }
            NumberAnimation { target: rowTransform; property: "x"; to: 20; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 2 }
            NumberAnimation { target: rowTransform; property: "x"; to: -20; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 2 }
            NumberAnimation { target: rowTransform; property: "x"; to: 20; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 2 }
            NumberAnimation { target: rowTransform; property: "x"; to: -20; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 2 }
            NumberAnimation { target: rowTransform; property: "x"; to: 20; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 2 }
            NumberAnimation { target: rowTransform; property: "x"; to: 0; duration: 100; easing.type: Easing.OutBack; easing.overshoot: 2 }
        }

        //  INFO: Left corner
        InvertedCorner {
            rounding: 30
            anchors.bottom: parent.bottom
            rotation: 90
            roundingColor:  Style.background
        }

        Rectangle {
            id: main
            width: 500
            height: 80
            color: Style.background
            topLeftRadius: 100
            topRightRadius: 100
            bottomLeftRadius: 0
            bottomRightRadius: 0

            Rectangle {
                id: passwordContainer
                anchors.fill: parent
                anchors {
                    topMargin: 10
                    leftMargin: 10
                    rightMargin: 10
                    bottomMargin: 5
                }
                color:  Style.surface
                border.color: Style.surfaceDim
                border.width: root.borderSize
                radius: 9999
                z: 3
                clip: true

                property int currentBorderIndex: 1

                Behavior on border.color { ColorAnimation { duration: 120 } }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true
                    color: Style.textSecondary
                    echoMode: TextInput.Password
                    opacity: 0

                    onTextChanged: {
                        while (passwordChars.count < this.text.length) passwordChars.append({});
                        while (passwordChars.count > this.text.length) passwordChars.remove(passwordChars.count - 1);

                        if (passwordInput.text.length > 0) {
                            root.rowVisible = true
                            hideTimer.restart()
                            passwordContainer.currentBorderIndex = (passwordContainer.currentBorderIndex + 1) % 4
                            resetUI()

                            if (this.text.length === LockScreenService.pinLength) {
                                LockScreenService.currentText = this.text
                                this.text = ""
                            }
                        } else {
                            passwordContainer.currentBorderIndex = 5
                        }
                    }

                    cursorDelegate: Component { Item { width: 0; height: 0; visible: false } }
                    font { family: Style.family; pixelSize: 30; weight: Font.Medium; styleName: "Medium"; letterSpacing: 5 }

                    Keys.onEscapePressed: root.clearAndHide()

                    onAccepted: {
                        if (this.text.length === 0) return
                        LockScreenService.currentText = this.text
                        this.text = ""
                        LockScreenService.tryUnlock()
                    }
                }

                Text {
                    id: passwordStatus
                    text: "Type your password..."
                    color: Style.textMuted

                    anchors.centerIn: parent
                    opacity: passwordInput.text ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: 300 } }

                    transform: Translate {
                        y: passwordInput.text ? 200 : 0

                        Behavior on y {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutBack
                                easing.overshoot: 1.2
                            }
                        }
                    }

                    font {
                        family: Style.family
                        pixelSize: 22
                        weight: Font.Bold
                        styleName: "Bold"
                    }
                }

                ListView {
                    id: passwordCharsView
                    anchors.fill: parent
                    model: passwordChars
                    orientation: ListView.Horizontal
                    interactive: false
                    anchors {
                        topMargin: parent.border.width
                        bottomMargin: parent.border.width
                        leftMargin: parent.border.width + 20
                        rightMargin: parent.border.width + 20
                    }
                    spacing: 5

                    property int itemsWidth: passwordChars.count > 0 ? (passwordChars.count * 30 + (passwordChars.count - 1) * spacing) : 0

                    contentX: Math.max(0, itemsWidth - width + 20)
                    Behavior on contentX { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                    anchors.horizontalCenter: parent.horizontalCenter

                    delegate: Item {
                        width: 30
                        height: passwordCharsView.height
                        Symbols {
                            icon: "circle"
                            size: 23
                            iconColor: Style.textSecondary
                            anchors.centerIn: parent
                        }
                    }

                    add: Transition {
                        ParallelAnimation {
                            NumberAnimation { property: "y"; from: 30; to: 0; duration: 150; easing.type: Easing.OutBack; easing.overshoot: 2 }
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 100 }
                        }
                    }

                    remove: Transition {
                        ParallelAnimation {
                            NumberAnimation { property: "opacity"; to: 0; duration: 150 }
                        }
                    }
                }

                //  INFO: This hides the chracters when they are animated
                Rectangle {
                    id: passwordContainerMask
                    anchors.fill: parent
                    radius: passwordContainer.radius
                    color: "transparent"
                    z: 10
                    border.color:  Style.surfaceDim
                    border.width: root.borderSize
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Rectangle {
                        width: parent.width + 14
                        height: parent.height + 14
                        radius: passwordContainer.radius
                        color: "transparent"
                        border.color:  Style.background
                        border.width: 7
                        anchors.centerIn: parent
                    }
                }

                //  INFO: Animated borders
                Rectangle {
                    width: parent.width / 2
                    height: parent.height / 2
                    clip: true
                    z: 11
                    color: "transparent"
                    opacity: passwordContainer.currentBorderIndex === 0 ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutBack
                        }
                    }

                    anchors {
                        top: parent.top
                        left: parent.left
                    }

                    Rectangle {
                        width: parent.width * 2
                        height: parent.height * 2

                        radius: 9999
                        color: "transparent"
                        border.color: Style.error
                        border.width: root.borderSize

                        anchors {
                            top: parent.top
                            left: parent.left
                        }
                    }
                }

                Rectangle {
                    width: parent.width / 2
                    height: parent.height / 2
                    clip: true
                    z: 11
                    color: "transparent"
                    opacity: passwordContainer.currentBorderIndex === 1 ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutBack
                        }
                    }

                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }

                    Rectangle {
                        width: parent.width * 2
                        height: parent.height * 2

                        radius: 9999
                        color: "transparent"
                        border.color: Style.success
                        border.width: root.borderSize

                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                        }
                    }
                }

                Rectangle {
                    width: parent.width / 2
                    height: parent.height / 2
                    clip: true
                    z: 11
                    color: "transparent"
                    opacity: passwordContainer.currentBorderIndex === 2 ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutBack
                        }
                    }

                    anchors {
                        top: parent.top
                        right: parent.right
                    }

                    Rectangle {
                        width: parent.width * 2
                        height: parent.height * 2

                        radius: 9999
                        color: "transparent"
                        border.color:  Style.warning
                        border.width: root.borderSize

                        anchors {
                            top: parent.top
                            right: parent.right
                        }
                    }
                }

                Rectangle {
                    width: parent.width / 2
                    height: parent.height / 2
                    clip: true
                    z: 11
                    color: "transparent"
                    opacity: passwordContainer.currentBorderIndex === 3 ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutBack
                        }
                    }

                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                    }

                    Rectangle {
                        width: parent.width * 2
                        height: parent.height * 2

                        radius: 9999
                        color: "transparent"
                        border.color: ColorEngine.monokai_fusion.purple5
                        border.width: root.borderSize

                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                        }
                    }
                }
            }
        }

        //  INFO: Right corner
        InvertedCorner {
            rounding: 30
            anchors.bottom: parent.bottom
            rotation: 180
            roundingColor: Style.background
        }
    }
}
