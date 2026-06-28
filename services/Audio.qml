pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio?.volume ?? 0.0
    readonly property bool isMuted: sink?.audio?.muted ?? false
    readonly property bool isMicMuted: source?.audio?.muted ?? false
    readonly property bool isBluetooth: {
        if (!sink)
        return false;
        let info = (sink.name + " " + sink.description + " " + sink.nickname).toLowerCase();
        return info.includes("bluez") || info.includes("bluetooth");
    }

    readonly property real hardMaxValue: 1.00
    property string audioTheme: "freedesktop"

    function friendlyDeviceName(node) {
        if (!node)
        return "Unknown";
        return node.nickname || node.description || "Unknown";
    }

    function appNodeDisplayName(node) {
        if (!node)
        return "Unknown";
        return node.properties["application.name"] || node.description || node.name || "Unknown";
    }

    readonly property var outputDevices: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var inputDevices: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)

    readonly property var outputStreams: Pipewire.nodes.values.filter(n => n.isSink && n.isStream && n.audio)
    readonly property var inputStreams: Pipewire.nodes.values.filter(n => !n.isSink && n.isStream && n.audio)

    readonly property string symbol: {
        if (isMuted || volume === 0)
        return "volume_off";

        if (isBluetooth)
        return "bluetooth_audio";

        if (volume < 0.33)
        return "volume_mute";

        if (volume < 0.67)
        return "volume_down";

        return "volume_up";
    }

    function toggleMute() {
        if (sink?.audio)
        sink.audio.muted = !sink.audio.muted;
    }

    function toggleMicMute() {
        if (source?.audio)
        source.audio.muted = !source.audio.muted;
    }

    function changeVolume(amount) {
        if (!sink?.audio)
        return;

        let newVolume = sink.audio.volume + amount;
        sink.audio.volume = Math.max(0.0, Math.min(hardMaxValue, newVolume));
    }

    function incrementVolume(by: double): void {
        changeVolume(by || 0.05);
    }

    function decrementVolume(by: double): void {
        changeVolume(-by || -0.05);
    }

    function setDefaultSink(node) {
        if (node)
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node) {
        if (node)
        Pipewire.preferredDefaultAudioSource = node;
    }

    function playSystemSound(soundName) {
        const cmd = `
        for ext in oga ogg wav; do
        file="/usr/share/sounds/${root.audioTheme}/stereo/${soundName}.$ext"
        if [ -f "$file" ]; then
        paplay "$file"
        break
        fi
        done
        `;

        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    function switchToDevice(node) {
        if (node) {
            Pipewire.preferredDefaultAudioSink = node;
        }
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
