pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.utils
import qs.theme

Singleton {
    id: root

    property var appList: []
    property bool isReady: false

    property var pinnedApps: []

    FileView {
        id: pinnedAppsFile
        path: Qt.resolvedUrl("../data/pinned_apps.jsonc")
        watchChanges: true

        onFileChanged: {
            pinnedAppsFile.reload();
        }

        onLoaded: {
            processFileContent();
        }

        onLoadFailed: error => {
            console.error("Failed to load pinned apps file: " + error);
        }
    }

    function processFileContent() {
        try {
            const rawData = JsoncParser.parse(pinnedAppsFile.text());
            root.pinnedApps = rawData.map(app => ({
                        class: app.class,
                        exec: app.exec || ""
                    }));
            root.updateAppList();
            root.isReady = true;
        } catch (e) {
            console.error("Failed to parse pinned apps JSONC: " + e);
        }
    }

    function getDisplayName(className) {
        if (!className)
            return "Unknown";
        const lower = className.toLowerCase();

        const nameOverrides = {
            "code": "VS Code",
            "code-url-handler": "VS Code",
            "code-oss": "VS Codium",
            "codium": "VS Codium",
            "kitty": "Terminal",
            "neovim": "Neovim",
            "vlc": "VLC",
            "gimp": "GIMP"
        };

        if (nameOverrides[lower])
            return nameOverrides[lower];

        try {
            if (typeof DesktopEntries !== "undefined" && typeof DesktopEntries.heuristicLookup === "function") {
                const entry = DesktopEntries.heuristicLookup(className);
                if (entry && entry.name)
                    return entry.name;
            }
        } catch (e) {
            console.warn("Display name lookup failed for " + className);
        }

        const parts = className.split(/[.\-_]/);
        const last = parts[parts.length - 1];
        return last.split(/(?=[A-Z])|[\s\-_]+/).map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");
    }

    property var _iconCache: ({})

    function launchApp(className, overrideExec) {
        if (overrideExec && overrideExec !== "") {
            Hyprland.dispatch(`hl.dsp.exec_cmd("${overrideExec}")`);
            return;
        }

        try {
            if (typeof DesktopEntries !== "undefined" && typeof DesktopEntries.heuristicLookup === "function") {
                const entry = DesktopEntries.heuristicLookup(className);
                if (entry && entry.desktopEntryName) {
                    Hyprland.dispatch(`hl.dsp.exec_cmd("gtk-launch ${entry.desktopEntryName}")`);
                    return;
                }
            }
        } catch (e) {
            console.warn("Desktop entry lookup failed for " + className);
        }

        Hyprland.dispatch(`hl.dsp.exec_cmd("gtk-launch ${className}")`);
    }

    function getCachedIconName(className) {
        if (!className)
            return "unknown";
        const lower = className.toLowerCase();

        if (root._iconCache[lower] !== undefined)
            return root._iconCache[lower];

        return "";
    }

    function getIconName(className) {
        let cached = getCachedIconName(className);
        if (cached !== "")
            return cached;

        const lower = className.toLowerCase();

        const iconOverrides = {
            "code": "visual-studio-code",
            "code-url-handler": "visual-studio-code",
            "code-oss": "vscodium",
            "vscodium": "vscodium",
            "kitty": "utilities-terminal",
            "org.gnome.nautilus": "system-file-manager",
            "neovim": "nvim",
            "io.github.kolunmi.bazaar": "software-store"
        };

        if (iconOverrides[lower]) {
            root._iconCache[lower] = iconOverrides[lower];
            return iconOverrides[lower];
        }

        try {
            if (typeof DesktopEntries !== "undefined" && typeof DesktopEntries.heuristicLookup === "function") {
                const appEntry = DesktopEntries.heuristicLookup(className);
                if (appEntry && appEntry.icon) {
                    root._iconCache[lower] = appEntry.icon;
                    return appEntry.icon;
                }
            }
        } catch (e) {
            console.warn("Auto-lookup failed for " + className);
        }

        root._iconCache[lower] = lower;
        return lower;
    }

    function updateAppList() {
        let clients = Hypr.windowList;
        let runningMap = {};

        clients.forEach(win => {
            if (!win.class)
                return;
            let cls = win.class.toLowerCase();

            if (!runningMap[cls]) {
                runningMap[cls] = {
                    class: win.class,
                    count: 0,
                    windows: []
                };
            }
            runningMap[cls].windows.push(win);
            runningMap[cls].count++;
        });

        let mergedList = [];

        root.pinnedApps.forEach(pinned => {
            let cls = pinned.class.toLowerCase();
            let isRunning = runningMap[cls] !== undefined;

            mergedList.push({
                class: pinned.class,
                exec: pinned.exec,
                isPinned: true,
                count: isRunning ? runningMap[cls].count : 0,
                windows: isRunning ? runningMap[cls].windows : []
            });

            if (isRunning)
                delete runningMap[cls];
        });

        Object.values(runningMap).forEach(app => {
            mergedList.push({
                class: app.class,
                exec: "",
                isPinned: false,
                count: app.count,
                windows: app.windows
            });
        });

        root.appList = mergedList;
    }

    Connections {
        target: Hypr
        function onWindowListChanged() {
            root.updateAppList();
        }
    }

    Component.onCompleted: {
        root.updateAppList();
    }
}
