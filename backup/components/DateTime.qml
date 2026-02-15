import "../globals"
import QtQuick
import Quickshell
import ".."

Text {
    id: dateDisplay
    color: Config.fg
    font {
        family: Config.font
        pixelSize: Config.fontSize
        bold: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateDisplay.text = new Date().toLocaleString(Qt.locale(), "ddd d MMM  HH:mm")
    }
}
