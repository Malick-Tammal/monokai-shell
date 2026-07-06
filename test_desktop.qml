import Quickshell
import QtQuick

ShellRoot {
    Component.onCompleted: {
        console.log("DesktopEntries type:", typeof DesktopEntries)
        if (typeof DesktopEntries !== "undefined") {
            console.log("apps length:", DesktopEntries.applications.length)
            for (let i = 0; i < Math.min(5, DesktopEntries.applications.length); i++) {
                console.log(DesktopEntries.applications[i].id)
            }
        }
        Qt.quit()
    }
}
