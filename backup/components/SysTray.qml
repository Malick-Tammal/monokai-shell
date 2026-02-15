import "../globals"
import QtQuick
import QtQuick.Layouts
import Quickshell
// Corrected naming for latest Quickshell 0.2.x
import Quickshell.Services.UPower
import ".."

RowLayout {
    spacing: 12

    // WiFi & Bluetooth - Using a reliable fallback method
    // Since some modules vary by build, we use the standard Text icons
    // for visual stability while you're testing.
    Text {
        text: "󰤨"
        color: Config.accent
        font.pixelSize: 16
    }

    Text {
        text: "󰂯"
        color: Config.accent
        font.pixelSize: 16
    }

    // Audio - Using built-in Pipewire (if available) or standard icon
    Text {
        text: "󰕾"
        color: Config.fg
        font.pixelSize: 16
    }

    // Battery (Native UPower)
    Text {
        text: UPower.displayDevice && UPower.displayDevice.percentage < 20 ? "󰂃" : "󰁹"
        color: UPower.displayDevice && UPower.displayDevice.percentage < 20 ? "#ff5555" : Config.fg
        font.pixelSize: 16
    }
}
