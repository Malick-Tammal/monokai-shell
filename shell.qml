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
import qs.core
import qs.theme
import "./modules/lockscreen/"

ShellRoot {
    id: root

    Loader {
        id: popupsLoader
        sourceComponent: undefined
        asynchronous: true
    }

    Loader {
        id: logsLoader
        sourceComponent: undefined
        asynchronous: true
        active: Configs.logs
    }

    Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: {
            popupsLoader.source = "./core/Popups.qml";
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            logsLoader.source = "./core/Logs.qml";
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
                anchors.fill: parent
                context: LockScreenService
            }
        }
    }
}
