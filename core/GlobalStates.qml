pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool powerMenuVisible: false
    property bool walliVisible: false
    property bool barVisible: false
    property bool trayVisible: false
}
