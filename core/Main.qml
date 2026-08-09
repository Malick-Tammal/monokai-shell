import "../modules/bar/"
import "../modules/dock/"
import "../modules/screen_corners/"
import QtQuick

Item {
    id: root

    required property var screen

    ScreenCorners {
        id: screenCorners

        screen: root.screen
    }

    Bar {
        id: bar

        screen: root.screen
    }

    Dock {
        id: dock

        screen: root.screen
    }

}
