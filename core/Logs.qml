import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.theme

Scope {
    id: root

    function logStamped(message) {
        let timestamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd - hh:mm:ss")
        console.log(`\u001b[32m[${timestamp}]\u001b[0m ${message}`)
    }

    function logSection(title) {
        let pad = "-".repeat(20)
        console.log(`\u001b[1;36m${pad} ${title} ${pad}\u001b[0m`)
    }

    function formatValue(val) {
        return typeof val === "object" ? JSON.stringify(val) : val
    }

    Process {
        id: bannerProc
        command: ["toilet", "-f", "future", "-w", "500", " LOGS ", "-F", "border", "--metal"]
        running: true

        stdout: SplitParser {
            onRead: data => console.log(`        ${data}`)
        }

        onExited: code => {
            if (code !== 0) {
                console.warn("[Warning] toilet banner failed to execute.")
            }
            console.log("")
            logging()
        }
    }

    function logging() {
        //--------------------------------------------
        //  INFO: Pywal
        //--------------------------------------------
        logSection("Pywal")
        logStamped(`Wallpaper path : ${Pywal.wallpaper}`)
        logStamped(`Colors         : ${formatValue(Pywal.colors)}`)
        logStamped(`Special colors : ${formatValue(Pywal.special)}`)

        console.log('')

        //--------------------------------------------
        //  INFO: Color Engine
        //--------------------------------------------
        logSection("Color Engine")
        logStamped(`Brightness     : ${ColorEngine.wallpaperBrightness}`)
        logStamped(`Is Dark Mode   : ${ColorEngine.isDark}`)

        console.log("")

        //--------------------------------------------
        //  INFO: Keyboard service
        //--------------------------------------------
        logSection("Keyboard Service")
        logStamped(`Layout         : ${KbService.currentLayout} (${KbService.shortLayout})`)
        logStamped(`Backlight      : Level ${KbService.backlightLevel}/${KbService.maxBacklightLevel} (${KbService.backlightPercent}%)`)

    }

    Component.onCompleted: {
        console.log("")
    }
}
