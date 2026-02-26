pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import Quickshell.Services.UPower

Singleton {
    id: root

    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool acConnected: isCharging || chargeState === UPowerDeviceState.PendingCharge || chargeState === UPowerDeviceState.FullyCharged
    property real percentage: UPower.displayDevice?.percentage ?? 1

    property bool isLow: available && (percentage <= 0.2)
    property bool isCritical: available && (percentage <= 0.05)
    property bool isSuspending: available && (percentage <= 0.03)
    property bool isFull: available && (percentage >= 1.01)

    property real energyRate: UPower.displayDevice.changeRate
    property real timeToEmpty: UPower.displayDevice.timeToEmpty
    property real timeToFull: UPower.displayDevice.timeToFull

    property real health: (function () {
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
