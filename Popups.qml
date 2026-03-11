import QtQuick
import "./modules/powermenu/"
import "./modules/walli/"
import "./modules/launcher/"

Item {
    id: root

    PowerMenu {
        id: powerMenu
    }

    Walli {
        id: walli
    }

    // Launcher {}
}
