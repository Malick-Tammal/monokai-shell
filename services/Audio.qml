pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    signal interactionTriggered()

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property real volume: sink?.audio?.volume ?? 0.
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

    IpcHandler {
        target: "volume"

        function increase(){
            incrementVolume()
            interactionTriggered()
        }

        function decrease(){
            decrementVolume()
            interactionTriggered()
        }

        function mute(){
            toggleMute()
            interactionTriggered()
        }
    }

    function friendlyDeviceName(node): string {
        if (!node)
        return "Unknown";
        return node.nickname || node.description || "Unknown";
    }

    function appNodeDisplayName(node): string {
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

    function toggleMute(): void {
        if (sink?.audio)
        sink.audio.muted = !sink.audio.muted;
        interactionTriggered()
    }

    function toggleMicMute(): void {
        if (source?.audio)
        source.audio.muted = !source.audio.muted;

    }

    function changeVolume(amount): void {
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

    function setDefaultSink(node): void {
        if (node)
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node): void {
        if (node)
        Pipewire.preferredDefaultAudioSource = node;
    }

    function playSystemSound(soundName): void {
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

    function switchToDevice(node): void {
        if (node) {
            Pipewire.preferredDefaultAudioSink = node;
        }
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
