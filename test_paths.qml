import Quickshell
import QtQuick

ShellRoot {
    Component.onCompleted: {
        console.log("configPath:", Quickshell.configPath)
        console.log("scriptPath:", Quickshell.scriptPath)
        Qt.quit()
    }
}
