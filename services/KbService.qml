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
                if (parts.length >= 2) {
                    const layout = parts[1].split(" ")[0];
                    const shortLayout = parts[1].trim().substring(0, 2).toUpperCase();
                    root.currentLayout = layout;
                    root.shortLayout = shortLayout;
                }
            }
        }
    }

    property var keys: ({
            "key_H": 43,
            "key_L": 46,
            "key_K": 45,
    })
}
