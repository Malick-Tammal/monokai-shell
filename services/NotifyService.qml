pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    property int notifCount: 0

    function send(title, body, iconPath) {
        let args = ["notify-send", title, body];

        iconPath && iconPath !== "" ? args.push("-i", iconPath) : "";

        Quickshell.execDetached(args);
    }

    Process {
        id: swayncListener
        running: true
        command: ["swaync-client", "--subscribe-waybar"]

        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "")
                    return;

                try {
                    let json = JSON.parse(data);

                    root.notifCount = parseInt(json.text, 10) || 0;
                } catch (e) {
                    console.error("Failed to parse swaync output:", e, "Raw data:", data);
                }
            }
        }
    }
}
