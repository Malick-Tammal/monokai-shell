pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property bool available: UPower.displayDevice.isLaptopBattery
    readonly property var chargeState: UPower.displayDevice.state
    readonly property bool isCharging: chargeState == UPowerDeviceState.Charging
    readonly property bool acConnected: isCharging || chargeState === UPowerDeviceState.PendingCharge || chargeState === UPowerDeviceState.FullyCharged
    readonly property real percentage: UPower.displayDevice?.percentage ?? 1

    readonly property bool isLow: available && (percentage <= 0.2)
    readonly property bool isCritical: available && (percentage <= 0.05)
    readonly property bool isSuspending: available && (percentage <= 0.03)
    readonly property bool isFull: available && (percentage >= 1.01)

    readonly property real energyRate: UPower.displayDevice.changeRate
    readonly property real timeToEmpty: UPower.displayDevice.timeToEmpty
    readonly property real timeToFull: UPower.displayDevice.timeToFull

    readonly property real health: (function () {
            const devList = UPower.devices.values;
            for (let i = 0; i < devList.length; ++i) {
                const dev = devList[i];
                if (dev.isLaptopBattery && dev.healthSupported) {
                    const health = dev.healthPercentage;
                    if (health === 0) {
                        return 0.01;
                    } else if (health < 1) {
                        return health * 100;
                    } else {
                        return health;
                    }
                }
            }
            return 0;
        })()
}
