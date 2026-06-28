//@ pragma UseQApplication
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma Env QT_AUTO_SCREEN_SCALE_FACTOR=0
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough

import Quickshell
import QtQuick
import Quickshell.Wayland
import Quickshell.Io
import qs.services
import "./modules/lockscreen/"

ShellRoot {
    id: root

    Loader {
        id: popupsLoader
        sourceComponent: undefined
    }

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            popupsLoader.source = "Popups.qml";
        }
    }

    Instantiator {
        model: Quickshell.screens
        delegate: Main {
            required property var modelData
            screen: modelData
        }
    }

    WlSessionLock {
        id: lock

        locked: LockScreenService.locked

        WlSessionLockSurface {
            LockSurface {
                context: LockScreenService
            }
        }
    }
}
