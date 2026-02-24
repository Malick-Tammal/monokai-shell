//@ pragma UseQApplication
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma Env QT_AUTO_SCREEN_SCALE_FACTOR=0
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma Env QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough

import Quickshell
import QtQuick

ShellRoot {
    id: root

    Loader {
        id: uiLoader
        sourceComponent: undefined
    }

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            uiLoader.source = "Main.qml";
        }
    }
}
