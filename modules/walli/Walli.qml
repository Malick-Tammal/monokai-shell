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
    // WlrLayershell.exclusiveZone: -1
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
    property int padding : 5

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
            if (!thumbGen.running) {
                thumbGen.running = true;
            }
            resetView();
            window.currentWall = "";
            swwwQuery.running = true;
        }
    }

    function resetView() {
        if (wallpapers.count > 0) {
            wallpapers.currentIndex = 0;
            wallpapers.positionViewAtBeginning();
            wallpapers.forceActiveFocus();
        }
    }

    function findAndSelect(cleanName) {
        for (var i = 0; i < wallpapers.count; i++) {
            var file = wallpapers.model.get(i, "fileName");
            var dbName = file.replace(/\.[^/.]+$/, "");

            if (dbName === cleanName) {
                print("Found match at index: " + i);
                wallpapers.currentIndex = i;
                wallpapers.positionViewAtIndex(i, ListView.Center);
                wallpapers.forceActiveFocus();
                return;
            }
        }

        if (wallpapers.count > 0) {
            print("No match found. Defaulting to first item.");
            window.resetView();
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: window.isVisible = false
    }

    // --- Processes ---
    Process {
        id: swwwProc
        command: ["swww", "img", "", "--transition-type", "grow", "--transition-pos", "0.5,0.5", "--transition-step", "90", "--transition-fps", "60"]

        onExited: code => {
            if (code === 0)
                print("Wallpaper applied successfully!");
        }
    }

    Process {
        id: thumbGen
        command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/walli_thumbs.sh"]
        running: false
    }

    Process {
        id: cacheWall
        command: ["cp", "", Quickshell.env("HOME") + "/.cache/current-wallpaper.png"]
        onExited: code => {
            if (code === 0)
                print("Wallpaper cached successfully!");
        }
    }

    Process {
        id: sddmWall
        command: ["cp", "", "/usr/share/sddm/themes/sddm-modern/wallpaper.png"]
        onExited: code => {
            if (code === 0)
                print("Wallpaper copied for sddm!");
        }
    }

    Process {
        id: swwwQuery
        command: ["swww", "query"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(": ");
                if (parts.length > 1) {
                    const fullPath = parts[parts.length - 1].trim();
                    const filename = fullPath.split("/").pop();
                    const cleanName = filename.replace(/\.[^/.]+$/, "");

                    print("Swww active wallpaper : " + filename);
                    window.currentWall = filename;
                    window.findAndSelect(filename);
                }
            }
        }
    }

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

            border.color: Style.dark4
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

                function activate(path) {
                    swwwProc.command[2] = path;
                    swwwProc.running = true;
                    cacheWall.command[1] = path;
                    cacheWall.running = true;
                    sddmWall.command[1] = path;
                    sddmWall.running = true;
                    window.isVisible = false;
                }

                Keys.onPressed: event => {
                    if (event.text === "h" || event.key === Qt.Key_Left) {
                        wallpapers.decrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.text === "l" || event.key === Qt.Key_Right) {
                        wallpapers.incrementCurrentIndex();
                        event.accepted = true;
                    } else if (event.text === "k" || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        let fileName = wallpapers.model.get(wallpapers.currentIndex, "fileName");
                        const mainFolder = Quickshell.env("HOME") + "/Pictures/Wallpapers/";
                        const fullPath = mainFolder + fileName;
                        const wallPath = fullPath.replace(".png", "");
                        activate(wallPath);
                        event.accepted = true;
                    }
                }

                model: FolderListModel {
                    folder: "file://" + Quickshell.env("HOME") + "/.cache/walli_thumbs/"
                    nameFilters: ["*.jpg", "*.png", "*.webp", "*.jpeg"]
                    showDirs: false
                }

                delegate: Item {
                    id: wrapper
                    width: (wallpapers.width - (5 * wallpapers.spacing)) / 6
                    height: wallpapers.height

                    Connections {
                        target: window

                        function onCurrentWallChanged() {
                            const myName = fileName.replace(/\.[^/.]+$/, "");

                            if (window.currentWall === "")
                                return;

                            if (myName === window.currentWall) {
                                wallpapers.currentIndex = index;
                                wallpapers.positionViewAtIndex(index, ListView.Center);
                                wallpapers.forceActiveFocus();
                            }
                        }
                    }

                    Rectangle {
                        id: container
                        anchors.fill: parent
                        radius: 10
                        color: index === wallpapers.currentIndex ? Style.yellow : Style.dark5

                        Inverted {
                            anchors.bottom: img.bottom
                            anchors.right: img.right
                            anchors.rightMargin: 5
                            anchors.bottomMargin: 47
                            rounding: 10
                            z: 2
                            visible: index === wallpapers.currentIndex ? true : false

                            roundingColor: Style.yellow
                            transform: Scale {
                                origin.y: 5
                                yScale: -1
                            }
                        }

                        Inverted {
                            anchors.bottom: img.bottom
                            anchors.left: img.left
                            anchors.leftMargin: 5
                            anchors.bottomMargin: 47
                            rounding: 10
                            z: 2

                            visible: index === wallpapers.currentIndex ? true : false
                            roundingColor: Style.yellow

                            transform: Scale {
                                origin.y: 5
                                yScale: 1
                            }
                            rotation: 180
                        }

                        Image {
                            id: img
                            source: fileUrl
                            width: container.width
                            height: container.height
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                            sourceSize.width: width
                            sourceSize.height: height
                        }

                        OpacityMask {
                            anchors.fill: container
                            anchors.margins: index === wallpapers.currentIndex ? 5 : 2
                            source: img
                            maskSource: Rectangle {
                                width: container.width
                                height: container.height
                                radius: 10
                            }
                        }

                        Rectangle {
                            height: parent.height / 6
                            color: Style.yellow
                            visible: index === wallpapers.currentIndex ? true : false

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
                            }
                        }
                    }
                }
            }
        }
    }
}
