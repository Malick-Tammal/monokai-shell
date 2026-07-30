pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var batteryDevice: {
        const devices = UPower.devices.values;
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].isLaptopBattery) return devices[i];
        }
        return UPower.displayDevice;
    }

    readonly property bool available: batteryDevice?.isLaptopBattery ?? false
    readonly property var chargeState: batteryDevice?.state ?? UPowerDeviceState.Unknown

    readonly property real percentage: batteryDevice.percentage ?? 1
    readonly property string percentageText: `${Math.round(percentage * 100)}%`

    readonly property bool isCharging: chargeState == UPowerDeviceState.Charging
    readonly property bool isPluggedIn: isCharging
    || chargeState == UPowerDeviceState.PendingCharge
    || chargeState == UPowerDeviceState.FullyCharged

    readonly property bool isLow: available && (percentage <= 0.2)
    readonly property bool isCritical: available && (percentage <= 0.05)
    readonly property bool isSuspending: available && (percentage <= 0.03)
    readonly property bool isFull: available && (percentage >= 0.99)

    readonly property real energyRate: batteryDevice.changeRate
    readonly property real timeToEmpty: batteryDevice.timeToEmpty
    readonly property real timeToFull: batteryDevice.timeToFull

    readonly property real health: batteryDevice.healthPercentage ?? 100.0
    readonly property string healthText: `${Math.round(health)}%`

    readonly property real currentCapacity: batteryDevice.energy
    readonly property real fullChargeCapacity: batteryDevice.energyCapacity
    readonly property real designCapacity: (health > 0) ? (fullChargeCapacity / (health / 100)) : 0.0
}
