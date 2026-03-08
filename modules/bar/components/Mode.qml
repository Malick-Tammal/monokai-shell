import QtQuick
import qs.theme
import qs.components
import qs.services

Item {
    id: root
    width: 28
    height: 28
    z: -1

    visible: ModeService.isActive ? true : false

    Behavior on visible {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
        }
    }

    transform: Translate {
        x: ModeService.isActive ? 0 : -50
        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutBack
            }
        }
    }

    Rectangle {
        id: indicatorCircle
        radius: 9999
        color: Style[ModeService.themeColor + "5"] || Style.gray5
        border.color: Style[ModeService.themeColor + "2"] || Style.gray2
        border.width: 2

        anchors {
            fill: parent
        }

        Symbols {
            icon: ModeService.currentIcon
            size: 15
            iconColor: Style[ModeService.themeColor + "9"] || Style.gray9
            weight: Font.Black
            anchors.centerIn: parent
        }
    }
}
