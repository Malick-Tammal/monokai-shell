pragma Singleton
import QtQuick

QtObject {
    readonly property color bg: "#242424" // Tokyo Night with Alpha
    readonly property color fg: "#cfc9c2"
    readonly property color accent: "#FFD600"
    readonly property color muted: "#3E3E3E"
    readonly property color border: "#3E3E3E"

    readonly property string font: "SF Pro Text"
    readonly property int fontSize: 13
    readonly property real radius: 10
}
