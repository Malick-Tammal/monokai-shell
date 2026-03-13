import QtQuick
import "./modules/powermenu/"
import "./modules/walli/"
import "./modules/launcher/"
import "./modules/overview/"

Item {
    id: root

    PowerMenu {
        id: powerMenu
    }

    Walli {
        id: walli
    }

    Overview {
        id: overview
    }

    // Launcher {}
}
