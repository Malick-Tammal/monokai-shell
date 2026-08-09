pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.utils
import qs.core

Singleton {
    id: root

    property bool enabled: false

    function activate(): void {
        void Hypr.applyConfig({
            "animations:enabled": false,
            "decoration:shadow:enabled": false,
            "decoration:blur:enabled": false,
            "general:gaps_in": 0,
            "general:gaps_out": 0,
            "general:border_size": 0,
            "decoration:rounding": 0,
            "general:allow_tearing": true,
            "plugin:hyprbars:enabled": false,
            "plugin:dynamic_cursors:enabled": false
        });
        root.enabled = true;
    }

    function restore(): void {
        Quickshell.execDetached(["hyprctl", "reload"]);
        root.enabled = false;
    }

    IpcHandler {
        target: "gamemode"

        function enable(): void {
            root.activate();
        }

        function disable(): void {
            root.restore();
        }

        function toggle(): void {
            if (root.enabled) {
                root.restore();
            } else {
                root.activate();
            }
        }
    }
}
