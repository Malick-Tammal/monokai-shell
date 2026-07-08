pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.core
import qs.theme

Singleton {
    id: root

    property int barHeight: 46

    signal toggleRequested(var targetScreen)
    signal revealRequested(var targetScreen)
    signal hideRequested(var targetScreen)

    IpcHandler {
        target: "bar"
        function toggle(): void {
            let activeScreenName = Hyprland.focusedMonitor?.name ?? "";
            root.toggleRequested(activeScreenName);
        }

        function reveal(): void {
            let activeScreenName = Hyprland.focusedMonitor?.name ?? "";
            root.revealRequested(activeScreenName);
        }

        function hide(): void {
            let activeScreenName = Hyprland.focusedMonitor?.name ?? "";
            root.hideRequested(activeScreenName);
        }
    }
}
