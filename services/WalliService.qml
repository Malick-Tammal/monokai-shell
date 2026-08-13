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

    property int _queryRetries: 0

    //  TIP: Awww Animation Settings
    property string _animationType: "wipe"
    property string _animationPos: "0.1 , 0.5"
    property string _animationBezier: ".23,.86,.81,.07"
    property int _animationStep: 120
    property int _animationFps: 60
    property int _animationAngle: 15
    property double _animationDuration: 1.6

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
        id: retryTimer
        interval: 400
        repeat: false
        onTriggered: awwwQuery.running = true
    }

    function _retryQuery(): void {
        if (root._queryRetries < 10) {
            root._queryRetries++;
            retryTimer.restart();
        } else {
            console.warn("WalliService: awww query failed after 10 retries. Applying fallback.");
            if (root.currentWallPath === "") {
                root.currentWallPath = Dirs.wallsFolder + "Courtside-Sunset.png";
                root.currentWall = "Courtside-Sunset";
                Matugen.generateColors(root.currentWallPath);
            }
        }
    }

    function activateWall(name): void {
        const cache = Dirs.walliCacheFolder + "walli_thumbs/" + name;
        const full = Dirs.wallsFolder + name;
        const cleanName = name.replace(/\.[^/.]+$/, "");

        if (full !== root.currentWallPath) {
            root.currentWall = cleanName;
            root.currentWallPath = full;

            Matugen.generateColors(full);

            awwwProc.command[2] = full;
            sddmWall.command[1] = full;

            awwwProc.running = true;
            sddmWall.running = true;

            NotifyService.send("walli", cleanName, cache);
        }

        GlobalStates.walliVisible = false;
    }

    Connections {
        target: Matugen

        function onWallPathChanged() {
            Configs.syncELKWithMatugen === true ? ElkService.setColor(Matugen.colors.primary) : null;
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
        command: ["awww", "img", "", "--transition-type", root._animationType, "--transition-pos", root._animationPos, "--transition-step", root._animationStep, "--transition-fps", root._animationFps, "--transition-angle", root._animationAngle, "--transition-bezier", root._animationBezier, "--transition-duration", root._animationDuration]
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
                if (!output) {
                    root._retryQuery();
                    return;
                }
                try {
                    const data = JSON.parse(output);
                    const keys = Object.keys(data);
                    const firstKey = keys.length > 0 ? keys[0] : "";
                    const monitors = data[firstKey];
                    if (monitors && monitors.length > 0 && monitors[0].displaying && monitors[0].displaying.image) {
                        const fullPath = monitors[0].displaying.image;
                        const filename = fullPath.split("/").pop();
                        const cleanName = filename.replace(/\.[^/.]+$/, "");
                        root._queryRetries = 0;
                        root.currentWall = cleanName;
                        root.currentWallPath = fullPath;
                    } else {
                        root._retryQuery();
                    }
                } catch (e) {
                    console.error("Failed to parse awww query JSON: " + e);
                    root._retryQuery();
                }
            }
        }
    }

    Component.onCompleted: awwwQuery.running = true
}
