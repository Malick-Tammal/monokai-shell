import QtQuick
import "../modules/screen_cornors/"
import "../modules/bar/"
import "../modules/dock/"

Item {
    id: root

    required property var screen

    ScreenCornors {
        id: screenCornors
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
