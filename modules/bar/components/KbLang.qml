import QtQuick
import qs.theme
import qs.components
import qs.services

Item {
    id: root
    height: parent.height
    width: row.implicitWidth + 10

    Behavior on width {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        transformOrigin: Item.Center

        SequentialAnimation {
            id: popAnim

            NumberAnimation {
                target: row
                property: "scale"
                to: 0.8
                duration: 50
                easing.type: Easing.OutQuad
            }

            NumberAnimation {
                target: row
                property: "scale"
                to: 1.0
                duration: 150
                easing.type: Easing.OutBack
            }
        }

        Symbols {
            icon: "keyboard"
            size: 13
            iconColor: Style.gray1
        }

        Text {
            text: KbService.shortLayout
            color: Style.gray1
            font {
                family: Style.family
                weight: Font.Bold
                pixelSize: Style.fontSizeSm
            }

            onTextChanged: popAnim.restart()
        }
    }
}
