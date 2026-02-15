import QtQuick

Item {
    id: root
    property string text: "00"

    width: 24
    height: 24
    clip: true

    Text {
        id: mainText
        text: root.text

        color: "#FDFFF1"
        font.pixelSize: 17
        font.family: "SF Pro Display"
        font.weight: Font.ExtraBold
        font.letterSpacing: 0.3

        anchors.horizontalCenter: parent.horizontalCenter
        y: (root.height - height) / 2
    }

    Text {
        id: nextText
        text: root.text

        color: "#FDFFF1"
        font.pixelSize: 17
        font.family: "SF Pro Display"
        font.weight: Font.ExtraBold
        font.letterSpacing: 0.3

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height
        visible: false
    }

    onTextChanged: {
        if (mainText.text !== text) {
            nextText.text = text;
            nextText.visible = true;
            anim.restart();
        }
    }

    ParallelAnimation {
        id: anim

        NumberAnimation {
            target: mainText
            property: "y"
            to: -root.height
            duration: 400
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: nextText
            property: "y"
            from: root.height
            to: (root.height - nextText.height) / 2
            duration: 400
            easing.type: Easing.InOutQuad
        }

        onFinished: {
            mainText.text = nextText.text;
            mainText.y = (root.height - mainText.height) / 2;
            nextText.visible = false;
        }
    }
}
