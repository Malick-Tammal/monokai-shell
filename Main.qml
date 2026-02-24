import Quickshell
import QtQuick
import "./modules/powermenu/"
import "./modules/walli/"
import "./modules/cornors/"
import "./modules/bar/"
import "./modules/dock/"
import "./modules/launcher/"

Item {
    id: mainRoot

    Cornors {}
    Bar {}
    PowerMenu {
        id: powerMenu
    }
    Walli {}
    Dock {}
    // Launcher {}
}
