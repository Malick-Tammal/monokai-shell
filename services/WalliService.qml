pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.services

Singleton {
    id: root

    property bool isVisible: false
    property string currentWall: ""
    property bool isLoading: false
    property string loadingText: "Checking wallpapers..."

    readonly property string wallsFolder: Quickshell.env("HOME") + "/Pictures/Wallpapers/"
    readonly property string cacheFolder: Quickshell.env("HOME") + "/.cache/walli_thumbs/"

    IpcHandler {
        target: "walli"
        function toggle(): void {
            root.isVisible = !root.isVisible;
        }
    }

    onIsVisibleChanged: {
        if (isVisible) {
            refreshTimer.restart();
            thumbGen.running = true;
        } else {
            root.isLoading = false;
        }
    }

    Timer {
        id: refreshTimer
        interval: 10
        repeat: false
        onTriggered: {
            root.currentWall = "";
            swwwQuery.running = true;
        }
    }

    function activateWall(name) {
        const cache = root.cacheFolder + name;
        const full = root.wallsFolder + name;

        swwwProc.command[2] = full;
        cacheWall.command[1] = full;
        sddmWall.command[1] = full;

        swwwProc.running = true;
        cacheWall.running = true;
        sddmWall.running = true;

        const cleanName = name.replace(/\.[^/.]+$/, "");
        NotifyService.send("walli", cleanName, cache);
        
        print(cleanName);
        print("cache : " + cache);
        print("wall : " + full);

        root.isVisible = false;
    }

    //  INFO: Processes ---

    // Thumbnail Generator
    Process {
        id: thumbGen
        command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/walli_thumbs.sh"]

        stdout: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (line === "STATUS:DETECTED") {
                    root.isLoading = true;
                    root.loadingText = "New wallpapers detected...";
                } else if (line.startsWith("STATUS:GENERATING:")) {
                    root.isLoading = true;
                    const parts = line.split(":");
                    if (parts.length >= 4) {
                        root.loadingText = "Generating wallpaper thumb (" + parts[2] + " of " + parts[3] + ")...";
                    }
                }
            }
        }

        onExited: {
            root.isLoading = false;
        }
    }

    // Apply wallpaper
    Process {
        id: swwwProc
        command: ["swww", "img", "", "--transition-type", "grow", "--transition-pos", "0.5,0.5", "--transition-step", "90", "--transition-fps", "60"]

        onExited: code => {
            if (code === 0) {
                root.isVisible = false;
            }
        }
    }

    // Helper Processes (Cache & SDDM)
    Process {
        id: cacheWall
        command: ["cp", "", Quickshell.env("HOME") + "/.cache/current-wallpaper.png"]
    }
    Process {
        id: sddmWall
        command: ["cp", "", "/usr/share/sddm/themes/sddm-modern/wallpaper.png"]
    }

    // Active Wallpaper Query
    Process {
        id: swwwQuery
        command: ["swww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                if (!output)
                    return;
                const parts = output.split(": ");
                if (parts.length > 1) {
                    const fullPath = parts[parts.length - 1].trim().split(",")[0];
                    const filename = fullPath.split("/").pop();
                    const cleanName = filename.replace(/\.[^/.]+$/, "");

                    root.currentWall = cleanName;
                }
            }
        }
    }
}
