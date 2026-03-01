pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property int focusedWorkspaceId: Hyprland.focusedWorkspace?.id ?? 0

    readonly property int lastVisibleWs: {
        let maxId = 7;
        let activeId = root.focusedWorkspaceId;

        if (activeId > maxId && activeId <= 10) {
            maxId = activeId;
        }

        let wsArray = Hyprland.workspaces.values;
        for (let i = 0; i < wsArray.length; ++i) {
            if (wsArray[i].id > maxId && wsArray[i].id <= 10) {
                maxId = wsArray[i].id;
            }
        }
        return maxId;
    }

    function hasWindows(id) {
        return Hyprland.workspaces.values.some(w => w.id === id);
    }

    function focusWorkspace(id) {
        Hyprland.dispatch("workspace " + id);
    }
}
