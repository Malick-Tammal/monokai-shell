import QtQuick
import "../modules/cornors/"
import "../modules/bar/"
import "../modules/dock/"

Item {
    id: root

    required property var screen

    Cornors {
        id: cornors
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
