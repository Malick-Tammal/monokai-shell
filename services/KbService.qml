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

    property int backlightLevel: 0
    property int maxBacklightLevel: 2
    property int backlightPercent: 0

    property string symbol: {
        if (backlightLevel === 0) {
            return "backlight_high_off"
        } else if (backlightLevel === 1) {
            return "backlight_low"
        } else if (backlightLevel === 2) {
            return "backlight_low"
        }
    }

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
            }
        }
    }

    Process {
        id: backlight
        command: ["brightnessctl", "-m", "-d", "*kbd_backlight*"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) return;

                const parts = text.trim().split(",");

                if (parts.length >= 5) {
                    const current = parseInt(parts[2]);
                    const percent = parseInt(parts[3].replace("%", ""));
                    const max = parseInt(parts[4]);

                    if (current !== root.backlightLevel) {
                        root.backlightLevel = current;
                        root.maxBacklightLevel = max;
                        root.backlightPercent = percent;

                        console.log(`Dell Backlight: Level ${current}/${max} (${percent}%)`);
                    }
                }
            }
        }
    }

    Process {
        id: dellDbusMonitor
        running: true
        command: ["dbus-monitor", "--system", "type='signal',interface='org.freedesktop.UPower.KbdBacklight'"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("BrightnessChanged")) {
                    if (!backlight.running) {
                        backlight.running = true;
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (!getLayout.running) { getLayout.running = true }
        if (!backlight.running) { backlight.running = true }
    }

    property var keys: ({
            "key_H": 43,
            "key_L": 46,
            "key_K": 45,
    })
}
