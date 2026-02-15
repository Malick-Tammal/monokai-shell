import QtQuick

Item {
    id: clock
    width: parent.width
    height: col.height

    Column {
        id: col
        anchors.centerIn: parent
        spacing: -2

        Sliding {
            id: hours
        }
        Sliding {
            id: minutes
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                let now = new Date();
                hours.text = Qt.formatTime(now, "hh");
                minutes.text = Qt.formatTime(now, "mm");
            }
        }
    }
}
