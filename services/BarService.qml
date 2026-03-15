pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs

Singleton {
    id: root

    property int barHeight: 40

    signal toggleRequested(var targetScreen)

    property bool isTransitioning: false

    Timer {
        id: transitionTimer
        interval: 300
        onTriggered: root.isTransitioning = false
    }

    Connections {
        target: GlobalStates

        function onBarVisibleChanged() {
            root.isTransitioning = true;
        }
    }

    readonly property bool isWorkspaceEmpty: Hypr.isWorkspaceEmpty

    readonly property bool barOverlapsWindow: {
        if (!Hypr.windowList || Hypr.windowList.length === 0)
            return false;

        const barBottomEdge = root.barHeight + GlobalStates.padding;
        const currentWsId = Hyprland.focusedWorkspace?.id ?? -999;

        return Hypr.windowList.some(win => {
            if (win.workspace.id !== currentWsId)
                return false;
            if (win.at[0] === -32000)
                return false;

            const winTopEdge = win.at[1];
            return winTopEdge < barBottomEdge;
        });
    }

    readonly property bool effectivelyOverlapped: root.isTransitioning ? !root.isWorkspaceEmpty : root.barOverlapsWindow

    readonly property bool isBarEffectivelyVisible: GlobalStates.barVisible || !root.effectivelyOverlapped

    IpcHandler {
        target: "bar"
        function toggle(): void {
            let activeScreenName = Hyprland.focusedMonitor?.name ?? "";
            root.toggleRequested(activeScreenName);
        }
    }
}
