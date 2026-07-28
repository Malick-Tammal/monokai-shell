pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property string currentLayout: ""
    property string shortLayout: ""

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                let parts = event.data.split(",");
                const layout = parts[1].split(" ")[0];
                if (parts.length >= 2) {
                    if (layout === "error") {
                        return;
                    } else {
                        const shortLayout = parts[1].trim().substring(0, 2).toUpperCase();
                        root.currentLayout = layout;
                        root.shortLayout = shortLayout;
                    }
                }
            }
        }
    }

    Process {
        id: getLayout
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parsed = JSON.parse(text);
                const activeKeymap = parsed.keyboards[0].active_keymap;
                const layout = activeKeymap.split(" ")[0];
                const shortLayout = activeKeymap.trim().substring(0, 2).toUpperCase();
                root.currentLayout = layout;
                root.shortLayout = shortLayout;
                console.log(shortLayout)
            }
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: getLayout.running = true
    }

    property var keys: ({
            "key_H": 43,
            "key_L": 46,
            "key_K": 45,
    })
}
