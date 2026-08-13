pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

Singleton {
    id: root

    property bool isInstalled: false

    property color pendingColor: "transparent"
    property bool colorPending: false

    property int pendingBrightness: -1
    property bool brightnessPending: false

    function setColor(newColor: color): void {
        if (!Configs.enableELK) {
            return;
        }

        pendingColor = newColor;
        colorPending = true;

        if (root.isInstalled) {
            colorDebounceTimer.restart();
        }
    }

    function turnOn(): void {
        if (!Configs.enableELK || !root.isInstalled)
            return;

        turnOnProc.running = true;
    }

    function turnOff(): void {
        if (!Configs.enableELK || !root.isInstalled)
            return;

        turnOffProc.running = true;
    }

    function setBrightness(brightness: int): void {
        if (!Configs.enableELK)
            return;

        if (brightness > 0 && brightness <= 100) {
            pendingBrightness = brightness;
            brightnessPending = true;
            if (root.isInstalled) {
                brightnessDebounceTimer.restart();
            }
        } else {
            console.log("brightness: " + brightness);
            console.log("Invalid range");
        }
    }

    function _executeColor() {
        if (!colorPending)
            return;

        if (setColorProc.running) {
            colorDebounceTimer.restart();
            return;
        }

        colorPending = false;

        let colorStr = String(pendingColor);
        let hex = colorStr.length === 9 ? "#" + colorStr.substring(3) : colorStr;

        setColorProc.command = ["elk-js", "color", hex];
        setColorProc.running = true;
    }

    function _executeBrightness() {
        if (!brightnessPending)
            return;

        if (brightnessProc.running) {
            brightnessDebounceTimer.restart();
            return;
        }

        brightnessPending = false;
        brightnessProc.command = ["elk-js", "brightness", String(pendingBrightness)];
        brightnessProc.running = true;
    }

    Timer {
        id: colorDebounceTimer
        interval: 50
        repeat: false
        onTriggered: root._executeColor()
    }

    Timer {
        id: brightnessDebounceTimer
        interval: 50
        repeat: false
        onTriggered: root._executeBrightness()
    }

    Process {
        id: setColorProc
        command: ["elk-js", "color", ""]
        running: false
    }

    Process {
        id: turnOnProc
        command: ["elk-js", "on"]
        running: false
    }

    Process {
        id: turnOffProc
        command: ["elk-js", "off"]
        running: false
    }

    Process {
        id: brightnessProc
        command: ["elk-js", "brightness", ""]
        running: false
    }

    Process {
        id: checkInstallProc
        command: ["which", "elk-js"]
        running: true

        onExited: function (code) {
            if (code === 0) {
                root.isInstalled = true;
                if (root.colorPending) {
                    colorDebounceTimer.restart();
                }
                if (root.brightnessPending) {
                    brightnessDebounceTimer.restart();
                }
            } else {
                root.colorPending = false;
                root.brightnessPending = false;
            }
        }
    }
}
