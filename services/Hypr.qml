pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property var windowList: []

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

    readonly property bool isWorkspaceEmpty: {
        if (!root.windowList || root.windowList.length === 0)
        return true;

        const currentWsId = Hyprland.focusedWorkspace?.id ?? -999;
        return !root.windowList.some(win => win.workspace.id === currentWsId);
    }

    property bool hyprbars: true

    function hasWindows(id) {
        return Hyprland.workspaces.values.some(w => w.id === id);
    }

    function focusWorkspace(id): void {
        Hyprland.dispatch(`hl.dsp.focus({workspace = ${id}})`);
    }

    Process {
        id: getClients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const clients = JSON.parse(text);
                    root.windowList = clients;
                } catch (e) {
                    console.error("Failed to parse hyprctl output");
                }
            }
        }
    }

    Process {
        id: checkHyprbars
        command: ["hyprpm", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                const cleanText = text.replace(/\x1b\[[0-9;]*m/g, '');
                const lines = cleanText.split("\n");

                let isEnabled = false;
                let foundPlugin = false;

                for (let i = 0; i < lines.length; i++) {
                    const currentLine = lines[i];

                    if (currentLine.includes("Plugin hyprbars")) {
                        foundPlugin = true;
                        continue;
                    }

                    if (foundPlugin) {
                        if (currentLine.trim() === "")
                        continue;

                        if (currentLine.includes("enabled: true")) {
                            isEnabled = true;
                        }
                        break;
                    }
                }

                root.hyprbars = isEnabled;
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: getClients.running = true
    }

    Timer {
        id: updateDebounce
        interval: 100
        repeat: false
        onTriggered: getClients.running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            updateDebounce.restart();

            if (event.name === "configreloaded") {
                checkHyprbars.running = true;
            }
        }
    }

    Component.onCompleted: {
        getClients.running = true;
        checkHyprbars.running = true;
    }
}
