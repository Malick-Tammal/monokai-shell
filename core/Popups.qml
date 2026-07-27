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

    // OSDs

    Volume {
        id: volume
    }

    Brightness {
        id: brightness
    }

    TopToast {
        id: topToast
    }
}
