import Quickshell
import QtQuick
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import qs.theme

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "overview"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusiveZone: -1

    property bool isVisible: false
    property var _workspaceData: []
    property string _focusedAddress: ""
    property int _activeWorkspaceIndex: 0

    property var _toplevelMap: ({})

    IpcHandler {
        target: "overview"
        function toggle() {
            root.isVisible = !root.isVisible;
        }
    }

    visible: container.opacity > 0 || isVisible

    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    color: "transparent"

    onIsVisibleChanged: {
        if (isVisible) {
            clientsProc.running = true;
        } else {
            clearTimer.start();
        }
    }

    Timer {
        id: clearTimer
        interval: 300 // Match the fade-out duration
        onTriggered: {
            root._workspaceData = [];
            root._toplevelMap = ({});
        }
    }

    // Fetch hyprctl clients
    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]

        stdout: StdioCollector {
            id: collector
            waitForEnd: true
            onStreamFinished: {
                root._parseClients(collector.text);
            }
        }
    }

    function _parseClients(jsonText) {
        try {
            var clients = JSON.parse(jsonText);
            var workspaces = {};
            var focusedAddr = "";
            var visibleClients = [];

            for (var i = 0; i < clients.length; i++) {
                var c = clients[i];

                // Skip floating, hidden, unmapped, special workspaces
                if (c.floating || c.hidden || !c.mapped)
                    continue;
                if (c.workspace.id < 0)
                    continue;

                var wsId = c.workspace.id;
                if (!workspaces[wsId]) {
                    workspaces[wsId] = {
                        id: wsId,
                        name: c.workspace.name,
                        windows: []
                    };
                }
                workspaces[wsId].windows.push(c);
                visibleClients.push(c);

                if (c.focusHistoryID === 0) {
                    focusedAddr = c.address;
                }
            }

            // Sort workspace ids ascending
            var sortedIds = Object.keys(workspaces).map(Number).sort(function (a, b) {
                return a - b;
            });
            var result = [];
            for (var j = 0; j < sortedIds.length; j++) {
                result.push(workspaces[sortedIds[j]]);
            }

            root._focusedAddress = focusedAddr;
            root._toplevelMap = _buildToplevelMap(visibleClients);
            root._workspaceData = result;

            // Find active workspace index
            var fw = Hyprland.focusedWorkspace;
            if (fw) {
                for (var k = 0; k < result.length; k++) {
                    if (result[k].id === fw.id) {
                        root._activeWorkspaceIndex = k;
                        break;
                    }
                }
            }
        } catch (e) {
            console.log("Overview: Failed to parse clients JSON:", e);
        }
    }

    function _focusWindow(address) {
        Hyprland.dispatch("focuswindow", "address:" + address);
        root.isVisible = false;
    }

    // Build a {address → Toplevel} map using greedy best-match.
    // Called once per toggle — pure function, no side effects.
    function _buildToplevelMap(clients) {
        var toplevelsList = ToplevelManager.toplevels.values;
        var map = {};
        var used = [];

        // Helper: check if appId matches class (exact or substring)
        function _classMatch(appId, cls) {
            if (appId === cls) return true;
            if (appId !== "" && (appId.indexOf(cls) !== -1 || cls.indexOf(appId) !== -1))
                return true;
            return false;
        }

        // Pass 1: Exact appId + exact title (strongest signal)
        for (var i = 0; i < clients.length; i++) {
            var c = clients[i];
            if (!c.class) continue;
            var cls = c.class.toLowerCase();

            for (var j = 0; j < toplevelsList.length; j++) {
                var tl = toplevelsList[j];
                if (!tl || used.indexOf(tl) !== -1) continue;

                var appId = (tl.appId || "").toLowerCase();
                if (_classMatch(appId, cls) && c.title && tl.title === c.title) {
                    map[c.address] = tl;
                    used.push(tl);
                    break;
                }
            }
        }

        // Pass 2: appId match + title substring (titles often differ between protocols)
        for (var i2 = 0; i2 < clients.length; i2++) {
            var c2 = clients[i2];
            if (map[c2.address]) continue;
            if (!c2.class) continue;
            var cls2 = c2.class.toLowerCase();
            var cTitle2 = (c2.title || "").toLowerCase();

            for (var j2 = 0; j2 < toplevelsList.length; j2++) {
                var tl2 = toplevelsList[j2];
                if (!tl2 || used.indexOf(tl2) !== -1) continue;

                var appId2 = (tl2.appId || "").toLowerCase();
                var tlTitle2 = (tl2.title || "").toLowerCase();
                if (_classMatch(appId2, cls2) && cTitle2 && tlTitle2
                    && (tlTitle2.indexOf(cTitle2) !== -1 || cTitle2.indexOf(tlTitle2) !== -1)) {
                    map[c2.address] = tl2;
                    used.push(tl2);
                    break;
                }
            }
        }

        // Pass 3: appId match only (class-only, no title requirement)
        for (var i3 = 0; i3 < clients.length; i3++) {
            var c3 = clients[i3];
            if (map[c3.address]) continue;
            if (!c3.class) continue;
            var cls3 = c3.class.toLowerCase();

            for (var j3 = 0; j3 < toplevelsList.length; j3++) {
                var tl3 = toplevelsList[j3];
                if (!tl3 || used.indexOf(tl3) !== -1) continue;

                var appId3 = (tl3.appId || "").toLowerCase();
                if (_classMatch(appId3, cls3)) {
                    map[c3.address] = tl3;
                    used.push(tl3);
                    break;
                }
            }
        }

        // Pass 4: Reuse already-assigned toplevels for still-unmatched windows.
        // A duplicate preview is better than no preview at all.
        for (var i4 = 0; i4 < clients.length; i4++) {
            var c4 = clients[i4];
            if (map[c4.address]) continue;
            if (!c4.class) continue;
            var cls4 = c4.class.toLowerCase();

            for (var j4 = 0; j4 < toplevelsList.length; j4++) {
                var tl4 = toplevelsList[j4];
                if (!tl4) continue;

                var appId4 = (tl4.appId || "").toLowerCase();
                if (_classMatch(appId4, cls4)) {
                    map[c4.address] = tl4;
                    break;
                }
            }
        }

        return map;
    }

    Shortcut {
        sequences: ["Escape"]
        onActivated: root.isVisible = false
    }

    // Backdrop click-to-dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: root.isVisible = false
    }

    Item {
        id: container
        anchors.fill: parent

        // Smooth opacity transition
        opacity: root.isVisible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        // Smooth zoom effect for Niri style
        scale: root.isVisible ? 1.0 : 1.05
        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack }
        }

        // Semi-transparent background
        Rectangle {
            anchors.fill: parent
            color: Style.dark7
            opacity: 0.85
        }

        // Title
        Text {
            id: title

            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Overview"
            font.family: Style.family
            font.pixelSize: Style.fontSizeXl
            font.bold: true
            color: Style.fg
        }

        // Workspace rows in a vertically centered ListView
        ListView {
            id: workspaceList

            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width

            model: root._workspaceData
            spacing: 16
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            orientation: ListView.Vertical
            
            // Snap to item
            snapMode: ListView.SnapToItem
            highlightMoveDuration: 250
            highlightMoveVelocity: -1

            // Extra padding so first/last workspace can reach center
            header: Item { width: 1; height: Math.max(0, workspaceList.height / 2 - 260) }
            footer: Item { width: 1; height: Math.max(0, workspaceList.height / 2 - 260) }

            delegate: WorkspaceRow {
                required property var modelData
                required property int index

                width: workspaceList.width
                workspaceId: modelData.id
                workspaceName: modelData.name
                isActive: {
                    var fw = Hyprland.focusedWorkspace;
                    return fw ? fw.id === modelData.id : false;
                }
                windows: modelData.windows
                monitorWidth: root.width
                monitorHeight: root.height
                focusedAddress: root._focusedAddress

                toplevelMap: root._toplevelMap

                onWindowClicked: function (address) {
                    root._focusWindow(address);
                }
            }

            // Snap to active workspace on data load
            onCountChanged: {
                if (count > 0) {
                    workspaceList.positionViewAtIndex(root._activeWorkspaceIndex, ListView.Center);
                }
            }
        }

        // Empty state message
        Text {
            visible: root._workspaceData.length === 0 && root.isVisible
            anchors.centerIn: parent

            text: "No windows"
            font.family: Style.family
            font.pixelSize: Style.fontSizeLg
            color: Style.gray3
        }
    }
}
