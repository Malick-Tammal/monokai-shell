import QtQuick
import "../modules/powermenu/"
import "../modules/walli/"
import "../modules/OSD/"

Item {
    id: root

    PowerMenu {
        id: powerMenu
    }

    Walli {
        id: walli
    }

    OSD {
        id: osd
    }
}
