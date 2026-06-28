pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    property bool wifi: true
    property bool ethernet: false

    property string networkName: "Disconnected"

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

        if (root.wifiStatus === "connected" && root.networkName !== "Disconnected" && root.networkName !== "") {
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
        command: ["sh", "-c", "echo \"$(nmcli -t -f DEVICE,NAME c show --active | awk -F: '$1 != \"lo\" && $1 !~ /^docker/ && $1 !~ /^veth/ && $1 !~ /^virbr/ {print $2; exit}')\""]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let name = data.trim();
                if (name !== "") {
                    root.networkName = name;
                } else if (root.wifiStatus === "connecting") {
                    root.networkName = "Connecting...";
                } else {
                    root.networkName = root.wifiEnabled ? "Disconnected" : "Disabled";
                }
            }
        }
    }
    Process {
        id: updateInterfaceName
        command: ["sh", "-c", "echo \"$(nmcli -t -f DEVICE c show --active | awk -F: '$1 != \"lo\" && $1 !~ /^docker/ && $1 !~ /^veth/ && $1 !~ /^virbr/ {print $1; exit}')\""]
        running: true
        stdout: SplitParser {
            onRead: data => root.interfaceName = data.trim()
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

    Timer {
        id: updateDebouncer
        interval: 200
        repeat: false
        onTriggered: {
            updateConnectionType.startCheck();
            wifiStatusProcess.running = true;
            updateNetworkName.running = true;
            updateInterfaceName.running = true;
            updateNetworkStrength.running = true;
            getNetworks.running = true;
        }
    }

    function update() {
        updateDebouncer.restart();
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
        stdout: SplitParser {
            onRead: data => {
                let enabled = data.trim() === "enabled";
                root.wifiEnabled = enabled;
                if (!enabled) {
                    root.networkName = "Disabled";
                    root.wifiStatus = "disabled";
                }
            }
        }
    }

    Process {
        id: updateConnectionType
        property string buffer
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE d status && nmcli -t -f CONNECTIVITY g"]

        function startCheck() {
            buffer = "";
            running = true;
        }

        stdout: SplitParser {
            onRead: data => updateConnectionType.buffer += data + "\n"
        }

        onExited: (exitCode, exitStatus) => {
            const lines = updateConnectionType.buffer.trim().split('\n');
            if (lines.length === 0 || lines[0] === "")
            return;

            const connectivity = lines.pop();
            let hasEthernet = false;
            let hasWifi = false;
            let newWifiStatus = root.wifiEnabled ? "disconnected" : "disabled";

            lines.forEach(line => {
                    if (line.startsWith("ethernet:") && line.includes("connected")) {
                        hasEthernet = true;
                    } else if (line.startsWith("wifi:")) {
                        if (line.includes("connected")) {
                            hasWifi = true;
                            newWifiStatus = "connected";
                            if (connectivity === "limited") {
                                hasWifi = false;
                                newWifiStatus = "limited";
                            }
                        } else if (newWifiStatus !== "connected") {
                            if (line.includes("connecting")) {
                                newWifiStatus = "connecting";
                            } else if (line.includes("disconnected") && newWifiStatus !== "connecting") {
                                newWifiStatus = "disconnected";
                            }
                        }
                    }
            });

            root.wifiStatus = newWifiStatus;
            root.ethernet = hasEthernet;
            root.wifi = hasWifi;

            if (!hasEthernet && newWifiStatus !== "connected") {
                root.interfaceName = "";
                if (newWifiStatus === "connecting") {
                    root.networkName = "Connecting...";
                } else if (newWifiStatus === "disabled" || !root.wifiEnabled) {
                    root.networkName = "Disabled";
                } else {
                    root.networkName = "Disconnected";
                }
            }
        }
    }

    Process {
        id: updateNetworkStrength
        running: true
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL device wifi | awk '/^\\*/ {print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                const cleanData = data.trim();
                if (cleanData) {
                    root.networkStrength = parseInt(cleanData, 10);
                } else {
                    root.networkStrength = 0;
                }
            }
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
        enableWifi(!root.wifiEnabled);
    }

    function rescanWifi(): void {
        root.wifiScanning = true;
        rescanProcess.running = true;
    }
}
