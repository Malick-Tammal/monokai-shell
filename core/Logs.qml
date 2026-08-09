import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.theme

Scope {
    id: root

    function _logStamped(message): void {
        let timestamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd - hh:mm:ss");
        console.log(`\u001b[32m[${timestamp}]\u001b[0m ${message}`);
    }

    function _logSection(title): void {
        let pad = "-".repeat(20);
        console.log(`\u001b[1;36m${pad} ${title} ${pad}\u001b[0m`);
    }

    function _formatValue(val): string {
        return typeof val === "object" ? JSON.stringify(val) : val;
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
                console.warn("[Warning] toilet banner failed to execute.");
            }
            console.log("");
            logging();
        }
    }

    function logging() {
        //--------------------------------------------
        //  INFO: Matugen
        //--------------------------------------------
        _logSection("Matugen");
        _logStamped(`Wallpaper path : ${Matugen.wallPath}`);
        _logStamped(`Colors         : ${_formatValue(Matugen.colors)}`);
        _logStamped(`Base16 : ${_formatValue(Matugen.base16)}`);

        console.log('');

        //--------------------------------------------
        //  INFO: Color Engine
        //--------------------------------------------
        _logSection("Color Engine");
        _logStamped(`Brightness       : ${ColorEngine.wallpaperBrightness}`);
        _logStamped(`Is Dark Mode     : ${ColorEngine.isDark}`);

        console.log("");

        //--------------------------------------------
        //  INFO: Keyboard service
        //--------------------------------------------
        _logSection("Keyboard Service");
        _logStamped(`Layout           : ${KbService.currentLayout} (${KbService.shortLayout})`);
        _logStamped(`Backlight        : Level ${KbService.backlightLevel}/${KbService.maxBacklightLevel} (${KbService.backlightPercent}%)`);

        console.log('');

        //--------------------------------------------
        //  INFO: Walli
        //--------------------------------------------
        _logSection("Walli");
        _logStamped(`Current wall     : ${WalliService.currentWall}`);
        _logStamped(`Current path     : ${WalliService.currentWallPath}`);
        _logStamped(`Cache path       : ${Dirs.walliCacheFolder}`);
        _logStamped(`Led strip color  : ${Matugen.colors.primary}`);
        _logStamped(`Is loading       : ${WalliService.isLoading}`);
    }

    Component.onCompleted: {
        console.log("");
    }
}
