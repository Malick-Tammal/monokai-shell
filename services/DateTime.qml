pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property date date: clock.date

    readonly property string hours: (clock.hours % 12 || 12).toString().padStart(2, '0')
    readonly property string minutes: clock.minutes.toString().padStart(2, '0')
    readonly property string seconds: clock.seconds.toString().padStart(2, '0')

    readonly property string ampm: clock.hours >= 12 ? "PM" : "AM"

    property string upTime: ""

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
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
