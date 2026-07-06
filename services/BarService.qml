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

    readonly property bool isWorkspaceEmpty: Hypr.isWorkspaceEmpty

    readonly property bool hasPhysicalOverlap: {
        if (!Hypr.windowList || Hypr.windowList.length === 0)
        return false;

        const barBottomEdge = root.barHeight + Style.globalPadding;
        const currentWsId = Hyprland.focusedWorkspace?.id ?? -999;

        return Hypr.windowList.some(win => {
                const isSpecialWs = (win.workspace.name && win.workspace.name.indexOf("special") !== -1) || win.workspace.id < 0;
                if (win.workspace.id !== currentWsId && !isSpecialWs)
                return false;

                if (win.at[0] === -32000 || win.mapped === false || win.hidden === true)
                return false;

                if (win.fullscreen)
                return true;

                const winTopEdge = Hypr.hyprbars ? win.at[1] - 35 : win.at[1];
                return winTopEdge < barBottomEdge;
        });
    }

    readonly property bool shouldIntellihide: {
        if (!GlobalStates.barVisible) {
            const currentWsId = Hyprland.focusedWorkspace?.id ?? -999;
            const hasPredictableOverlap = Hypr.windowList.some(win => {
                    const isSpecialWs = (win.workspace.name && win.workspace.name.indexOf("special") !== -1) || win.workspace.id < 0;
                    if (win.workspace.id !== currentWsId && !isSpecialWs) return false;
                    if (win.at[0] === -32000 || win.mapped === false || win.hidden === true) return false;

                    return (win.floating === false) || (win.fullscreen === true);
            });

            if (hasPredictableOverlap) return true;
        }

        return hasPhysicalOverlap;
    }

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
