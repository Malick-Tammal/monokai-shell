pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: service

    property var windowList: []
    property var appList: []

    property var pinnedApps: [
        {
            class: "io.github.kolunmi.Bazaar",
            exec: "bazaar"
        },
        {
            class: "org.gnome.Nautilus",
            exec: "nautilus --new-window"
        },
        {
            class: "firefox",
            exec: "firefox"
        },
        {
            class: "kitty",
            exec: "kitty"
        },
        {
            class: "neovim",
            exec: "kitty --class neovim -e nvim"
        },
        {
            class: "code",
            exec: "code"
        },
        {
            class: "codium",
            exec: "vscodium"
        },
        {
            class: "figma-linux",
            exec: "figma-linux"
        },
        {
            class: "upscayl",
            exec: "flatpak run org.upscayl.Upscayl"
        },
        {
            class: "gimp",
            exec: "gimp"
        },
        {
            class: "obsidian",
            exec: "obsidian"
        },
        {
            class: "foliate",
            exec: "flatpak run com.github.johnfactotum.Foliate"
        },
        {
            class: "io.github.alainm23.planify",
            exec: "flatpak run io.github.alainm23.planify"
        },
        {
            class: "org.gnome.Evince",
            exec: "evince"
        },
        {
            class: "steam",
            exec: "steam"
        },
        {
            class: "discord",
            exec: "discord"
        },
        {
            class: "vesktop",
            exec: "vesktop"
        },
        {
            class: "vlc",
            exec: "vlc"
        },
    ]

    function getIconName(className) {
        if (!className)
            return "unknown";
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
            return iconOverrides[lower];
        }

        try {
            if (typeof DesktopEntries !== "undefined" && typeof DesktopEntries.heuristicLookup === "function") {
                const appEntry = DesktopEntries.heuristicLookup(className);

                if (appEntry && appEntry.icon) {
                    return appEntry.icon;
                }
            }
        } catch (e) {
            console.warn("Auto-lookup failed for " + className);
        }

        return lower;
    }

    Process {
        id: getClients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const clients = JSON.parse(text);
                    service.windowList = clients;

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

                    service.pinnedApps.forEach(pinned => {
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

                    service.appList = mergedList;
                } catch (e) {
                    console.error("Failed to parse hyprctl output");
                }
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
        }
    }

    Component.onCompleted: getClients.running = true
}
