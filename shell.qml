import Quickshell
import Quickshell.Io
import QtQuick
import "./modules/powermenu/"
import "./modules/walli/"
import "./modules/cornors/"
import "./modules/bar/"
import "./modules/dock/"
import "./modules/launcher/"

ShellRoot {
    id: root

    PowerMenu {}
    Walli {}
    Cornors {}
    // Bar {}
    Dock {}
    // Launcher {}
}
