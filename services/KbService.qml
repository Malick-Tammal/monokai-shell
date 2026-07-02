pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentLayout: "..."
    property string shortLayout: ".."

    function formatLayout(fullName) {
        let lower = fullName.toLowerCase();

        if (lower.includes("english"))
        return "EN";
        if (lower.includes("arabic"))
        return "AR";
        if (lower.includes("french"))
        return "FR";

        return fullName.substring(0, 2).toUpperCase();
    }

    Process {
        id: layoutListener

        command: ["bash", "-c", "hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -n1; socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do if [[ \"$line\" == activelayout* ]]; then echo \"$line\" | cut -d',' -f2; fi; done"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let layoutName = data.trim();
                if (layoutName !== "") {
                    root.currentLayout = layoutName;
                    root.shortLayout = root.formatLayout(layoutName);
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
