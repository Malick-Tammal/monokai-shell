pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services

Singleton {
    id: root

    property int padding: 10

    property bool powerMenuVisible: false
    property bool walliVisible: false

    property bool barVisible: false
    property int barHeight: 40

    readonly property bool barOverlapsWindow: {
        if (!Hypr.windowList || Hypr.windowList.length === 0)
            return false;

        const barBottomEdge = root.barHeight + root.padding;
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

    readonly property bool isBarEffectivelyVisible: root.barVisible || !root.barOverlapsWindow
}
