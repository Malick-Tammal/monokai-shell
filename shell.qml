import Quickshell
import QtQuick
import "./modules/powermenu/"
import "./modules/walli/"
import "./modules/cornors/"
import "./modules/bar/"
import "./modules/dock/"
import "./modules/launcher/"

ShellRoot {
    id: root

    Cornors {}

    Bar {}

    PowerMenu {
        id: powerMenu
    }

    Walli {}
    // Dock {}
    // Launcher {}
}
