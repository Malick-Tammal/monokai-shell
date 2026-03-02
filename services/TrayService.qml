pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    property var items: SystemTray.items
}
