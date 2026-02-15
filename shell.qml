import Quickshell
import Quickshell.Io
import QtQuick
import "./modules/powermenu/"
import "./modules/walli/"
import "./modules/cornors/"
import "./modules/bar/"
import "./modules/dock/"

ShellRoot {
    id: root

    PowerMenu {}
    Walli {}
    Cornors {}
    Bar {}
    Dock {}
}
