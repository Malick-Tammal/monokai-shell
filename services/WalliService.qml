pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.services
import qs.core
import qs.theme

Singleton {
    id: root

    property string currentWall: ""
    property string currentWallPath: ""
    property bool isLoading: false
    property string loadingText: "Checking wallpapers..."

    //  TIP: Animation Settings
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
            awwwQuery.running = true;
        }
    }

    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered: awwwQuery.running = true;
    }

    function activateWall(name) {
        const cache = root.cacheFolder + name
        const full = root.wallsFolder + name
        const cleanName = name.replace(/\.[^/.]+$/, "")

        if (full !== root.currentWallPath) {
            root.currentWall = cleanName
            root.currentWallPath = full

            MatugenService.generateColors(full)

            awwwProc.command[2] = full
            sddmWall.command[1] = full

            awwwProc.running = true
            sddmWall.running = true

            NotifyService.send("walli", cleanName, cache)

            console.log('-------------------- Walli Log --------------------')
            console.log(`cache : ${cache}`)
            console.log(`active wallpaper : ${full}`)
        }

        GlobalStates.walliVisible = false
    }

    Connections {
        target: MatugenService

        function onWallPathChanged() {
            ledStrip.command[2] = MatugenService.colors.primary;
            ledStrip.running = true;
            console.log(`ledstrip color : ${MatugenService.colors.primary}`);
        }
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
    }

    // Cache wallpaper for SDDM
    Process {
        id: sddmWall
        command: ["cp", "", "/usr/share/sddm/themes/sddm-modern/wallpaper.png"]
    }

    // Active Wallpaper Query
    Process {
        id: awwwQuery
        command: ["awww", "query", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                if (!output) return;
                try {
                    const data = JSON.parse(output);
                    const monitors = data[""];
                    if (monitors && monitors.length > 0 && monitors[0].displaying && monitors[0].displaying.image) {
                        const fullPath = monitors[0].displaying.image;
                        const filename = fullPath.split("/").pop();
                        const cleanName = filename.replace(/\.[^/.]+$/, "");
                        root.currentWall = cleanName;
                        root.currentWallPath = fullPath;
                    }
                } catch(e) {
                    console.error("Failed to parse awww query JSON: " + e);
                }
            }
        }
    }

    Process {
        id: ledStrip
        command: [Quickshell.env("HOME") + "/.config/hypr/scripts/ELK.py", "color", ""]
    }
}
