pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    property bool wifi: true
    property bool ethernet: false

    property string networkName: ""

    property bool wifiEnabled: false
    property string wifiStatus: "disconnected"

    property string interfaceName: ""
    property int networkStrength: 0

    property bool wifiScanning: false
    property var wifiNetworks: []

    property string symbol: {
        if (root.ethernet)
            return "lan";

        if (!root.wifiEnabled || root.wifiStatus === "disabled") {
            return "signal_wifi_bad";
        }

        if (root.wifiStatus === "disconnected")
            return "wifi_find";
        if (root.wifiStatus === "connecting")
            return "wifi_add";

        if (root.wifiStatus === "connected") {
            let s = root.networkStrength;
            if (s > 83)
                return "signal_wifi_4_bar";
            if (s > 67)
                return "network_wifi";
            if (s > 50)
                return "network_wifi_3_bar";
            if (s > 33)
                return "network_wifi_2_bar";
            if (s > 17)
                return "network_wifi_1_bar";
            return "signal_wifi_0_bar";
        }

        return "signal_wifi_off";
    }

    Process {
        id: updateNetworkName
        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => root.networkName = data.trim()
        }
    }

    Process {
        id: getNetworks
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const allNetworks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]) || 0,
                        frequency: parseInt(net[2]) || 0,
                        ssid: net[3] || "",
                        bssid: net[4]?.replace(rep2, ":") ?? "",
                        security: net[5] || ""
                    };
                }).filter(n => n.ssid && n.ssid.length > 0);

                const networkMap = new Map();
                for (const network of allNetworks) {
                    const existing = networkMap.get(network.ssid);
                    if (!existing || (network.active && !existing.active) || (!network.active && !existing.active && network.strength > existing.strength)) {
                        networkMap.set(network.ssid, network);
                    }
                }

                root.wifiNetworks = Array.from(networkMap.values()).sort((a, b) => b.strength - a.strength);
            }
        }
    }

    Process {
        id: rescanProcess
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        stdout: SplitParser {
            onRead: {
                root.wifiScanning = false;
                getNetworks.running = true;
            }
        }
    }

    function update() {
        updateConnectionType.startCheck();
        wifiStatusProcess.running = true;
        updateNetworkName.running = true;
        updateNetworkStrength.running = true;
        updateInterfaceName.running = true;
        getNetworks.running = true;
    }

    Process {
        id: subscriber
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: root.update()
        }
    }

    Timer {
        id: strengthUpdater
        interval: 5000
        running: root.wifiStatus === "connected" && !root.ethernet
        repeat: true
        onTriggered: updateNetworkStrength.running = true
    }

    Process {
        id: wifiStatusProcess
        command: ["nmcli", "radio", "wifi"]
        Component.onCompleted: running = true
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    Process {
        id: updateConnectionType
        property string buffer
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE d status && nmcli -t -f CONNECTIVITY g"]
        running: true
        function startCheck() {
            buffer = "";
            updateConnectionType.running = true;
        }
        stdout: SplitParser {
            onRead: data => updateConnectionType.buffer += data + "\n"
        }
        onExited: (exitCode, exitStatus) => {
            const lines = updateConnectionType.buffer.trim().split('\n');
            const connectivity = lines.pop();
            let hasEthernet = false;
            let hasWifi = false;
            let wifiStatus = "disconnected";

            lines.forEach(line => {
                if (line.includes("ethernet") && line.includes("connected"))
                    hasEthernet = true;
                else if (line.includes("wifi:")) {
                    if (line.includes("disconnected")) {
                        wifiStatus = "disconnected";
                    } else if (line.includes("connected")) {
                        hasWifi = true;
                        wifiStatus = "connected";
                        if (connectivity === "limited") {
                            hasWifi = false;
                            wifiStatus = "limited";
                        }
                    } else if (line.includes("connecting")) {
                        wifiStatus = "connecting";
                    } else if (line.includes("unavailable")) {
                        wifiStatus = "disabled";
                    }
                }
            });

            root.wifiStatus = wifiStatus;
            root.ethernet = hasEthernet;
            root.wifi = hasWifi;
        }
    }

    Process {
        id: updateInterfaceName
        command: ["sh", "-c", "nmcli -t -f DEVICE connection show --active | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => root.interfaceName = data.trim()
        }
    }

    Process {
        id: updateNetworkStrength
        running: true
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\*/{if (NR!=1) {print $2}}'"]
        stdout: SplitParser {
            onRead: data => root.networkStrength = parseInt(data) || 0
        }
    }

    Process {
        id: enableWifiProc
    }

    function enableWifi(enabled = true): void {
        const cmdText = enabled ? "on" : "off";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmdText]);
    }

    function toggleWifi(): void {
        enableWifi(!wifiEnabled);
    }

    function rescanWifi(): void {
        wifiScanning = true;
        rescanProcess.running = true;
    }
}
