pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal interactionTriggered()

    property real brightness: 0.5
    readonly property real step: 0.10

    readonly property string symbol: {
        // if (brightness > 0.5) {
        //     return "brightness_7";
        // } else if (brightness <= 0.5) {
        //     return "brightness_6";
        // } else if (brightness < 0.25) {
        //     return "brightness_4";
        // }

        if (brightness <= 0.25) {
            return "brightness_4";
        } else if (brightness <= 0.5) {
            return "brightness_6";
        } else if (brightness > 0.5) {
            return "brightness_7";
        }
    }

    IpcHandler {
        target: "brightness"

        function increase() {
            increaseBrightness();
            interactionTriggered();
        }

        function decrease() {
            decreaseBrightness();
            interactionTriggered();
        }
    }

    function setBrightness(value: real): void {
        value = Math.round(Math.max(0.01, Math.min(1.0, value)) * 100) / 100;

        if (root.brightness === value)
        return;

        root.brightness = value;

        const percent = Math.round(value * 100);
        Quickshell.execDetached(["brightnessctl", "s", `${percent}%`]);

    }

    function increaseBrightness(): void {
        setBrightness(root.brightness + step);
    }

    function decreaseBrightness(): void {
        setBrightness(root.brightness - step);
    }

    Process {
        running: true
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                if (parts.length >= 4) {
                    const percentVal = parseInt(parts[3]);
                    if (!isNaN(percentVal)) {
                        root.brightness = percentVal / 100.0;
                    }
                }
            }
        }
    }
}
