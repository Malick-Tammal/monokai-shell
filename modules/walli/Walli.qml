import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import "../../components/"
import "../../theme/"

PanelWindow {
    id: window

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "walli"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    color: "transparent"

    property bool isVisible: false
    property string currentWall: ""
    property int padding: 10
    readonly property string wallsFolder: Quickshell.env("HOME") + "/Pictures/Wallpapers/"
    readonly property string cacheFolder: Quickshell.env("HOME") + "/.cache/walli_thumbs/"

    visible: isVisible

    IpcHandler {
        target: "walli"
        function toggle(): void {
            window.isVisible = !window.isVisible;
        }
    }

    Shortcut {
        sequences: ["Escape", "Backspace", "q"]
        onActivated: {
            window.isVisible = false;
        }
    }

    onVisibleChanged: {
        if (visible) {
            wallpapers.forceActiveFocus();
            refreshTimer.restart();
        }
    }

    Timer {
        id: refreshTimer
        interval: 10
        repeat: false
        onTriggered: {
            window.currentWall = "";
            swwwQuery.running = true;
        }
    }

    // --- Helper Functions ---
    function findAndSelect(cleanName) {
        if (wallpapers.count === 0)
            return;

        for (let i = 0; i < wallpapers.count; i++) {
            let file = wallpapers.model.get(i, "fileName");
            if (file.includes(cleanName)) {
                wallpapers.currentIndex = i;
                wallpapers.positionViewAtIndex(i, ListView.Center);
                return;
            }
        }
        wallpapers.currentIndex = 0;
        wallpapers.positionViewAtBeginning();
    }

    function activateWall(name): void {
        const wallName = name.replace(".png", "");
        const cache = cacheFolder + name;
        const full = wallsFolder + wallName;

        swwwProc.command[2] = full;
        cacheWall.command[1] = full;
        sddmWall.command[1] = full;

        swwwProc.running = true;
        cacheWall.running = true;
        sddmWall.running = true;

        notify.send("walli", wallName, cache);

        print(wallName);
        print("cache : " + cache);
        print("wall : " + full);

        isVisible = false;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: window.isVisible = false
    }

    //  INFO: Processes ---

    // Thumbnail Generator
    Process {
        id: thumbGen
        command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/walli_thumbs.sh"]
        running: true
    }

    // Apply wallpaper
    Process {
        id: swwwProc
        command: ["swww", "img", "", "--transition-type", "grow", "--transition-pos", "0.5,0.5", "--transition-step", "90", "--transition-fps", "60"]

        onExited: code => {
            if (code === 0) {
                window.isVisible = false;
            }
        }
    }

    // Helper Processes (Cache & SDDM)
    Process {
        id: cacheWall
        command: ["cp", "", Quickshell.env("HOME") + "/.cache/current-wallpaper.png"]
    }
    Process {
        id: sddmWall
        command: ["cp", "", "/usr/share/sddm/themes/sddm-modern/wallpaper.png"]
    }

    // Notification Helper
    Notify {
        id: notify
    }

    // Active Wallpaper Query
    Process {
        id: swwwQuery
        command: ["swww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                if (!output)
                    return;
                const parts = output.split(": ");
                if (parts.length > 1) {
                    const fullPath = parts[parts.length - 1].trim().split(",")[0];
                    const filename = fullPath.split("/").pop();
                    const cleanName = filename.replace(/\.[^/.]+$/, "");

                    window.currentWall = cleanName;
                    window.findAndSelect(cleanName);
                }
            }
        }
    }

    //  INFO: UI
    Rectangle {
        implicitWidth: parent.width
        implicitHeight: 300

        color: "transparent"

        anchors {
            top: parent.top
            right: parent.right
            horizontalCenter: parent.horizontalCenter
            margins: {
                top: window.padding;
                left: window.padding;
                right: window.padding;
            }
        }

        Rectangle {
            id: main

            anchors {
                fill: parent
            }

            border.color: Style.border
            border.width: 1
            antialiasing: true

            color: Style.bg
            radius: 15

            ListView {
                id: wallpapers
                anchors.fill: parent
                orientation: ListView.Horizontal
                spacing: 10
                anchors.margins: 10
                clip: true
                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds
                focus: true

                highlightFollowsCurrentItem: true
                highlightMoveDuration: 100
                highlightMoveVelocity: 10
                flickDeceleration: 1000
                maximumFlickVelocity: 5000
                cacheBuffer: 1000

                Keys.onPressed: event => {
                    if (event.text === "h" || event.key === Qt.Key_Left) {
                        decrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.text === "l" || event.key === Qt.Key_Right) {
                        incrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.text === "k" || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        const fileName = wallpapers.model.get(wallpapers.currentIndex, "fileName");
                        window.activateWall(fileName);
                        event.accepted = true;
                    }
                }

                model: FolderListModel {
                    folder: "file://" + window.cacheFolder
                    nameFilters: ["*.jpg", "*.png", "*.webp", "*.jpeg"]
                    showDirs: false
                    sortField: FolderListModel.Name
                }

                delegate: Item {
                    id: wrapper
                    width: (wallpapers.width - (5 * wallpapers.spacing)) / 6
                    height: wallpapers.height

                    property bool isSelected: index === wallpapers.currentIndex

                    HoverHandler {
                        id: hoverHandler
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            wallpapers.currentIndex = index;
                            wallpapers.forceActiveFocus();
                        }
                        onDoubleClicked: {
                            window.activateWall(fileName);
                        }
                    }

                    Rectangle {
                        id: container
                        anchors.fill: parent
                        radius: 10
                        color: isSelected || hoverHandler.hovered ? Style.yellow5 : Style.gray3

                        Inverted {
                            anchors.bottom: selWallName.top
                            anchors.right: selWallName.right
                            rounding: 10
                            z: 2
                            visible: isSelected ? true : false
                            roundingColor: Style.yellow5
                            rotation: 90
                        }

                        Inverted {
                            anchors.bottom: selWallName.top
                            anchors.left: selWallName.left
                            rounding: 10
                            z: 2
                            visible: isSelected ? true : false
                            roundingColor: Style.yellow5
                            rotation: 180
                        }

                        Image {
                            id: img
                            source: fileUrl
                            width: container.width
                            height: container.height
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            mipmap: true
                            asynchronous: true
                            visible: false
                            sourceSize.width: width
                            sourceSize.height: height
                        }

                        OpacityMask {
                            anchors.fill: container
                            anchors.margins: isSelected ? 5 : 1
                            source: img
                            maskSource: Rectangle {
                                width: container.width
                                height: container.height
                                radius: 10
                            }
                        }

                        Rectangle {
                            id: selWallName
                            height: parent.height / 6
                            color: Style.yellow5
                            visible: isSelected ? true : false

                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: 5
                            }

                            Text {
                                id: wallName
                                text: {
                                    var cleanName = fileName.replace(".png", "");
                                    var maxLength = 20;

                                    if (cleanName.length > maxLength) {
                                        return cleanName.substring(0, maxLength) + "...";
                                    }
                                    return cleanName;
                                }
                                anchors.centerIn: parent
                                font.family: Style.family
                                font.pixelSize: Style.fontSizeMd
                                font.weight: Font.Medium
                                color: Style.bg
                            }
                        }
                    }
                }
            }
        }
    }
}
