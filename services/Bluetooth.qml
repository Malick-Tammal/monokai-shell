pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    // --- Core Adapter Stats ---
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool isAvailable: Bluetooth.adapters.values.length > 0
    readonly property bool isEnabled: adapter?.enabled ?? false
    readonly property bool isDiscovering: adapter?.discovering ?? false

    // --- Connected Device Stats ---
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property int activeCount: connectedDevices.length
    readonly property bool isConnected: activeCount > 0

    readonly property string currentDeviceName: {
        if (!isEnabled)
            return "Off";
        if (activeCount === 0)
            return "Disconnected";
        if (activeCount === 1)
            return connectedDevices[0].name;
        return activeCount + " Devices Connected";
    }

    readonly property var deviceList: {
        let devices = [...Bluetooth.devices.values];

        return devices.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;

            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;

            let rssiA = a.rssi ?? -100;
            let rssiB = b.rssi ?? -100;
            if (rssiA !== rssiB)
                return rssiB - rssiA;

            return (a.name || "").localeCompare(b.name || "");
        });
    }

    readonly property string symbol: {
        if (!isAvailable || !isEnabled)
            return "bluetooth_disabled";

        if (isDiscovering)
            return "bluetooth_searching";

        if (isConnected)
            return "bluetooth_connected";

        return "bluetooth";
    }

    function toggleBluetooth() {
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
    }

    function toggleDeviceConnection(device) {
        if (!device)
            return;
        if (device.connected) {
            device.disconnectDevice();
        } else {
            device.connectDevice();
        }
    }

    function toggleDiscovery() {
        if (adapter) {
            let startScanning = !adapter.discovering;

            adapter.discovering = startScanning;

            if (startScanning) {
                discoveryTimer.restart();
            } else {
                discoveryTimer.stop();
            }
        }
    }

    Timer {
        id: discoveryTimer
        interval: 12000
        repeat: false
        onTriggered: {
            if (adapter) {
                adapter.discovering = false;
            }
        }
    }
}
