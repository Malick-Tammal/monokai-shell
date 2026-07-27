pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool powerMenuVisible: false
    property bool walliVisible: false

    property bool barVisible: false
    property bool isBarHovered: false

    property bool trayVisible: false
    property bool trayOverflowVisible: false

    property bool volumeOsd
    property bool brightnessOsd

    property bool showToast
}
