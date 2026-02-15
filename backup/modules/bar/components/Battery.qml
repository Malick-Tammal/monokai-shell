import QtQuick

Item {
    id: battery
    width: batteryIcon.width
    height: batteryIcon.height

    Rectangle {
        id: batteryIcon

        width: 20
        height: 30
        radius: 8
        color: "#FFD766"

        Text {
            text: "70"
            font.pixelSize: 12
            font.weight: Font.ExtraBold
            anchors.centerIn: parent
        }
    }
}
