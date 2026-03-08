import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import qs.components
import qs.services
import qs.theme

PanelWindow {
    id: window

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "walli"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    color: "transparent"

    property int padding: 10
    
    visible: WalliService.isVisible

    Connections {
        target: WalliService
        function onIsVisibleChanged() {
            if (!WalliService.isLoading && WalliService.isVisible) {
                wallpapers.forceActiveFocus();
            }
        }
        function onIsLoadingChanged() {
            if (!WalliService.isLoading && WalliService.isVisible) {
                wallpapers.forceActiveFocus();
            }
        }
        function onCurrentWallChanged() {
            if (WalliService.currentWall !== "") {
                window.findAndSelect(WalliService.currentWall);
            }
        }
    }

    Shortcut {
        sequences: ["Escape", "Backspace", "q"]
        onActivated: {
            WalliService.isVisible = false;
        }
    }

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

    MouseArea {
        anchors.fill: parent
        onClicked: WalliService.isVisible = false
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
                orientation: ListView.Horizontal
                spacing: 10
                anchors {
                    margins: 10
                    fill: parent
                }
                clip: true
                snapMode: ListView.SnapToItem
                boundsBehavior: Flickable.StopAtBounds
                focus: true
                enabled: !WalliService.isLoading

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
                        WalliService.activateWall(fileName);
                        event.accepted = true;
                    }
                }

                model: FolderListModel {
                    folder: "file://" + WalliService.cacheFolder
                    nameFilters: ["*.jpg", "*.png", "*.webp", "*.jpeg"]
                    showDirs: false
                    sortField: FolderListModel.Time
                    sortReversed: false
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
                            WalliService.activateWall(fileName);
                        }
                    }

                    Rectangle {
                        id: container
                        anchors.fill: parent
                        radius: 10
                        color: isSelected || hoverHandler.hovered ? Style.yellow5 : Style.gray3

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
                        }

                        property real maskMargin: isSelected ? 5 : 1

                        Behavior on maskMargin {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.Bezier
                            }
                        }

                        OpacityMask {
                            anchors {
                                fill: container
                                margins: container.maskMargin
                            }
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
                            width: parent.width + 5
                            color: Style.yellow5
                            visible: isSelected ? true : false
                            opacity: isSelected ? 1.0 : 0.0

                            transform: Translate {
                                y: isSelected ? 0 : 100

                                Behavior on y {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.Bezier
                                    }
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 50
                                    easing.type: Easing.Bezier
                                }
                            }

                            Inverted {
                                anchors {
                                    bottom: selWallName.top
                                    right: selWallName.right
                                }
                                rounding: 10
                                z: 2
                                visible: isSelected ? true : false
                                roundingColor: Style.yellow5
                                rotation: 90
                            }

                            Inverted {
                                anchors {
                                    bottom: selWallName.top
                                    left: selWallName.left
                                }
                                rounding: 10
                                z: 2
                                visible: isSelected ? true : false
                                roundingColor: Style.yellow5
                                rotation: 180
                            }

                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: 5
                            }

                            Text {
                                id: wallName
                                text: {
                                    var cleanName = fileName.replace(/\.[^/.]+$/, "");
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

            Rectangle {
                id: loadingOverlay
                width: parent.width - 3
                height: parent.height - 3
                anchors.centerIn: parent
                radius: 15
                z: 10

                color: Style.bg
                visible: opacity > 0.01
                opacity: WalliService.isLoading ? 0.9 : 0.0

                states: State {
                    name: "loading"
                    when: WalliService.isLoading
                    PropertyChanges {
                        target: loadingOverlay
                        opacity: 0.9
                    }
                }

                transitions: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: WalliService.loadingText
                    font.family: Style.family
                    font.pixelSize: Style.fontSizeLg
                    font.weight: Font.Medium
                    color: Style.yellow5
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}
