pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string date: Qt.formatDate(clock.date, "ddd, MMM d")

    readonly property string _fullTime: Qt.formatTime(clock.date, "hh:mm:ss AP")

    readonly property string hours: _fullTime.substring(0, 2)
    readonly property string minutes: _fullTime.substring(3, 5)
    readonly property string seconds: _fullTime.substring(6, 8)
    readonly property string ampm: _fullTime.substring(9, 11)

    property string upTime: ""

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Timer {
        id: uptimeTimer
        interval: 300000
        running: true
        repeat: true
        onTriggered: {
            upTimeProc.running = true;
        }
    }

    Process {
        id: upTimeProc
        command: ["uptime", "-p"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let clean = this.text.trim();

                let h = 0;
                let m = 0;

                let matchH = clean.match(/(\d+)\s+hours?/);
                if (matchH)
                    h = matchH[1];

                let matchM = clean.match(/(\d+)\s+minutes?/);
                if (matchM)
                    m = matchM[1];

                root.upTime = `${h} Hours , ${m} Mins`;
            }
        }
    }
}
