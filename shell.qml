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

    PowerMenu {
        id: powerMenu
    }
    Walli {}
    Cornors {}
    Bar {}
    // Dock {}
    // Launcher {}
}
