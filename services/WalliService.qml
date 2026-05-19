pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.services
import qs

Singleton {
    id: root

    property string currentWall: ""
    property bool isLoading: false
    property string loadingText: "Checking wallpapers..."

    property string animationType: "wipe"
    property string animationPos: "0.1 , 0.5"
    property string animationBezier: ".23,.86,.81,.07"
    property int animationStep: 120
    property int animationFps: 60
    property int animationAngle: 15
    property double animationDuration: 1.6

    readonly property string wallsFolder: Quickshell.env("HOME") + "/Pictures/Wallpapers/"
    readonly property string cacheFolder: Quickshell.env("HOME") + "/.cache/walli_thumbs/"

    IpcHandler {
        target: "walli"
        function toggle(): void {
            GlobalStates.walliVisible = !GlobalStates.walliVisible;
        }
    }

    Connections {
        target: GlobalStates
        function onWalliVisibleChanged() {
            if (GlobalStates.walliVisible) {
                refreshTimer.restart();
                thumbGen.running = true;
            } else {
                root.isLoading = false;
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 10
        repeat: false
        onTriggered: {
            root.currentWall = "";
            awwwQuery.running = true;
        }
    }

    function activateWall(name) {
        const cache = root.cacheFolder + name;
        const full = root.wallsFolder + name;

        awwwProc.command[2] = full;
        cacheWall.command[1] = full;
        sddmWall.command[1] = full;

        awwwProc.running = true;
        cacheWall.running = true;
        sddmWall.running = true;

        const cleanName = name.replace(/\.[^/.]+$/, "");
        NotifyService.send("walli", cleanName, cache);

        print(cleanName);
        print("cache : " + cache);
        print("wall : " + full);

        GlobalStates.walliVisible = false;
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
        id: awwwProc
        command: ["awww", "img", "", "--transition-type", root.animationType, "--transition-pos", root.animationPos, "--transition-step", root.animationStep, "--transition-fps", root.animationFps, "--transition-angle", root.animationAngle, "--transition-bezier", root.animationBezier, "--transition-duration", root.animationDuration]

        onExited: code => {
            if (code === 0) {
                GlobalStates.walliVisible = false;
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
        id: awwwQuery
        command: ["awww", "query"]
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
