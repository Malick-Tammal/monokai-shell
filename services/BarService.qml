pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    signal toggleRequested(var targetScreen)

    IpcHandler {
        target: "bar"
        function toggle(): void {
            let activeScreenName = Hyprland.focusedMonitor?.name ?? "";
            root.toggleRequested(activeScreenName);
        }
    }
}
