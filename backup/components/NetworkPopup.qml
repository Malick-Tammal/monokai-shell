import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../globals"

PopupWindow {
    id: root

    // --- 1. SAFE GEOMETRY ---
    // We stick to standard anchoring to prevent "y" errors.
    implicitWidth: 340
    implicitHeight: 480

    anchor.window: barWindow
    anchor.rect.x: (parentWindow?.width ?? 0) - implicitWidth - 12
    anchor.rect.y: (parentWindow?.height ?? 0) + 8

    color: "transparent"

    // --- 2. CLICK OUTSIDE (Hyprland Native) ---
    // This hooks into Hyprland directly to detect clicks elsewhere.
    HyprlandFocusGrab {
        id: focusGrab
        active: root.visible
        windows: [root]
        onCleared: root.visible = false
    }

    // --- 3. ESCAPE KEY (Focus Force) ---
    onVisibleChanged: {
        if (visible) {
            internalState = 0;
            // Force focus so Escape key works
            focusTimer.restart();
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        repeat: false
        onTriggered: mainFocus.forceActiveFocus()
    }

    // --- 4. BACKEND LOGIC ---
    property int internalState: 0
    function forceRefresh() {
        internalState = 1;
        uiSpinTimer.restart();
        if (!rescanTrigger.running && !hardwareWaitTimer.running) {
            if (wifiReader.running)
                wifiReader.running = false;
            rescanTrigger.running = true;
        }
    }

    Timer {
        id: uiSpinTimer
        interval: 1500
        repeat: false
        onTriggered: {
            if (!wifiReader.running && !hardwareWaitTimer.running && !rescanTrigger.running)
                internalState = 0;
        }
    }
    Timer {
        id: hardwareWaitTimer
        interval: 2000
        repeat: false
        onTriggered: wifiReader.running = true
    }
    Timer {
        id: watchdog
        interval: 10000
        running: internalState === 1
        onTriggered: {
            internalState = 0;
            rescanTrigger.running = false;
            wifiReader.running = false;
        }
    }
    Process {
        id: rescanTrigger
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: hardwareWaitTimer.restart()
    }

    Process {
        id: wifiReader
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SECURITY,SIGNAL", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                let rawList = [];
                let lines = this.text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (line === "")
                        continue;
                    let parts = line.split(":");
                    if (parts.length >= 4 && parts[1] !== "") {
                        let isActive = parts[0] === "yes";
                        let ssid = parts[1];
                        let secure = parts[2] !== "";
                        let signal = parseInt(parts[3]) || 0;
                        let existingIndex = -1;
                        for (let k = 0; k < rawList.length; k++) {
                            if (rawList[k].ssid === ssid)
                                existingIndex = k;
                        }
                        if (existingIndex !== -1) {
                            if (isActive || (rawList[existingIndex].signal < signal && !rawList[existingIndex].active))
                                rawList[existingIndex] = {
                                    "active": isActive,
                                    "ssid": ssid,
                                    "secure": secure,
                                    "signal": signal
                                };
                        } else
                            rawList.push({
                                "active": isActive,
                                "ssid": ssid,
                                "secure": secure,
                                "signal": signal
                            });
                    }
                }
                rawList.sort((a, b) => {
                    if (a.active)
                        return -1;
                    if (b.active)
                        return 1;
                    return b.signal - a.signal;
                });
                wifiModel.clear();
                for (let j = 0; j < rawList.length; j++)
                    wifiModel.append(rawList[j]);
                if (!uiSpinTimer.running)
                    internalState = 0;
            }
        }
    }
    Process {
        id: statusCheck
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: toggleSwitch.checked = (this.text.trim() === "enabled")
        }
    }
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            if (root.visible && internalState === 0) {
                statusCheck.running = true;
                wifiReader.running = true;
            }
        }
    }
    Component.onCompleted: {
        statusCheck.running = true;
        wifiReader.running = true;
    }
    Process {
        id: commandRunner
        command: []
    }

    // --- 5. UI LAYOUT ---

    FocusScope {
        id: mainFocus
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.visible = false

        Rectangle {
            anchors.fill: parent
            color: Config.bg
            radius: 16
            border.color: "#45475a"
            border.width: 1
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                spacing: 10

                Text {
                    text: "Wi-Fi"
                    color: Config.fg
                    font.family: Config.font
                    font.pixelSize: 18
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                // REFRESH
                Item {
                    width: 30
                    height: 30
                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        color: internalState === 1 ? Config.accent : Config.muted
                        font.family: Config.font
                        font.pixelSize: 20
                        RotationAnimator on rotation {
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                            running: internalState === 1
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.forceRefresh()
                    }
                }

                // TOGGLE
                Rectangle {
                    id: toggleSwitch
                    width: 44
                    height: 24
                    radius: 12
                    color: checked ? Config.accent : "#363a4f"
                    property bool checked: true
                    Rectangle {
                        x: parent.checked ? 22 : 2
                        y: 2
                        width: 20
                        height: 20
                        radius: 10
                        color: "white"
                        Behavior on x {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCirc
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let newState = !parent.checked ? "on" : "off";
                            commandRunner.command = ["nmcli", "radio", "wifi", newState];
                            commandRunner.running = true;
                            parent.checked = !parent.checked;
                            if (newState === "on")
                                root.forceRefresh();
                            else {
                                wifiModel.clear();
                                internalState = 0;
                            }
                        }
                    }
                }

                // CLOSE BUTTON (Fixed Z-Index & Hitbox)
                Rectangle {
                    width: 30
                    height: 30
                    color: "transparent" // Hitbox only
                    z: 999 // Ensure it sits on top of everything

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeMouse.containsMouse ? "#ff6b6b" : Config.muted
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Close Clicked");
                            root.visible = false;
                        }
                    }
                }
            }

            Item {
                height: 12
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#303244"
            }
            Item {
                height: 12
                Layout.fillWidth: true
            }

            ListView {
                id: wifiList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: ListModel {
                    id: wifiModel
                }
                ScrollBar.vertical: ScrollBar {
                    active: true
                    width: 4
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    width: wifiList.width - 8
                    height: 44
                    color: model.active ? Qt.rgba(Config.accent.r, Config.accent.g, Config.accent.b, 0.15) : "transparent"
                    radius: 8
                    border.width: model.active ? 1 : 0
                    border.color: model.active ? Config.accent : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12
                        Text {
                            text: {
                                if (model.signal > 75)
                                    return "󰤨";
                                if (model.signal > 50)
                                    return "󰤥";
                                if (model.signal > 25)
                                    return "󰤢";
                                return "󰤟";
                            }
                            color: model.active ? Config.accent : Config.fg
                            font.pixelSize: 18
                        }
                        Text {
                            text: model.ssid
                            color: model.active ? Config.accent : Config.fg
                            font.family: Config.font
                            font.bold: true
                            font.pixelSize: 14
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            visible: model.active
                            text: "Connected"
                            color: Config.accent
                            font.family: Config.font
                            font.pixelSize: 11
                        }
                        Text {
                            visible: model.secure && !model.active
                            text: ""
                            color: Config.muted
                            font.pixelSize: 14
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: if (!model.active)
                            parent.color = "#1affffff"
                        onExited: if (!model.active)
                            parent.color = "transparent"
                        onClicked: {
                            commandRunner.command = ["nm-connection-editor"];
                            commandRunner.running = true;
                        }
                    }
                }
            }
            Item {
                height: 12
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: "#252535"
                radius: 8
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: ""
                        color: Config.fg
                        font.family: Config.font
                    }
                    Text {
                        text: "Network Settings"
                        color: Config.fg
                        font.family: Config.font
                        font.bold: true
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.color = "#303045"
                    onExited: parent.color = "#252535"
                    onClicked: {
                        commandRunner.command = ["nm-connection-editor"];
                        commandRunner.running = true;
                    }
                }
            }
        }
    }
}
