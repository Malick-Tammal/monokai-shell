import Quickshell
import Quickshell.Wayland
import QtQuick
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import qs.components
import qs.services
import qs.theme
import qs.core

PanelWindow {
    id: window

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "walli"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"

    visible: GlobalStates.walliVisible

    onVisibleChanged: {
        if (visible && !WalliService.isLoading) {
            wallpapers.forceActiveFocus();
            if (WalliService.currentWall !== "") {
                window.findAndSelect(WalliService.currentWall);
            }
        }
    }

    Connections {
        target: WalliService
        function onIsLoadingChanged() {
            if (!WalliService.isLoading && GlobalStates.walliVisible) {
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
        onActivated: GlobalStates.walliVisible = false
    }

    Timer {
        id: scrollTimer
        interval: 20
        repeat: false
        onTriggered: {
            if (wallpapers.currentIndex >= 0) {
                wallpapers.positionViewAtIndex(wallpapers.currentIndex, ListView.Center);
            } else {
                wallpapers.positionViewAtBeginning();
            }
        }
    }

    function findAndSelect(cleanName) {
        if (wallpapers.count === 0)
            return;

        for (let i = 0; i < wallpapers.count; i++) {
            let file = wallpapers.model.get(i, "fileName");
            if (file.includes(cleanName)) {
                wallpapers.currentIndex = i;
                scrollTimer.restart();
                return;
            }
        }
        wallpapers.currentIndex = 0;
        scrollTimer.restart();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: GlobalStates.walliVisible = false
    }

    //  INFO: UI
    Rectangle {
        implicitWidth: parent.width
        implicitHeight: 360

        color: "transparent"

        anchors {
            top: parent.top
            right: parent.right
            horizontalCenter: parent.horizontalCenter
            leftMargin: Style.globalPadding
            rightMargin: Style.globalPadding
            topMargin: (GlobalStates.isBarHovered || GlobalStates.barVisible) ? BarService.barHeight + Style.globalPadding * 2 : Style.globalPadding

            Behavior on topMargin {
                SpringAnimation {
                    spring: 10
                    damping: 0.5
                    mass: 1.5
                }
            }
        }

        Rectangle {
            id: main

            anchors {
                fill: parent
                top: parent.top
            }

            border.color: Style.border
            border.width: 1
            antialiasing: true

            color: Style.background
            radius: 25

            MouseArea {
                anchors.fill: parent
            }

            ListView {
                id: wallpapers

                property int visibleWallpaperCount: 6

                onCountChanged: {
                    if (window.visible && WalliService.currentWall !== "") {
                        window.findAndSelect(WalliService.currentWall);
                    }
                }

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
                    const isShift = (event.modifiers & Qt.ShiftModifier);
                    const code = event.nativeScanCode;

                    if ((code === KbService.keys.key_H && !isShift) || event.key === Qt.Key_Left) {
                        decrementCurrentIndex();
                        event.accepted = true;
                    } else if ((code === KbService.keys.key_L && !isShift) || event.key === Qt.Key_Right) {
                        incrementCurrentIndex();
                        event.accepted = true;
                    } else if (code === KbService.keys.key_H && isShift) {
                        wallpapers.currentIndex = Math.max(0, wallpapers.currentIndex - (visibleWallpaperCount - 1));
                        event.accepted = true;
                    } else if (code === KbService.keys.key_L && isShift) {
                        wallpapers.currentIndex = Math.max(0, wallpapers.currentIndex + (visibleWallpaperCount - 1));
                        event.accepted = true;
                    } else if ((code === KbService.keys.key_K && !isShift) || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        const fileName = wallpapers.model.get(wallpapers.currentIndex, "fileName");
                        WalliService.activateWall(fileName);
                        event.accepted = true;
                    }
                }

                model: FolderListModel {
                    folder: "file://" + Dirs.walliCacheFolder
                    nameFilters: ["*.jpg", "*.png", "*.webp", "*.jpeg"]
                    showDirs: false
                    sortField: FolderListModel.Time
                    sortReversed: false
                }

                delegate: Item {
                    id: wrapper
                    width: (wallpapers.width - (5 * wallpapers.spacing)) / wallpapers.visibleWallpaperCount
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
                        radius: 15
                        color: isSelected || hoverHandler.hovered ? Style.warning : Style.borderDim

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
                                duration: 70
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
                                radius: 15
                            }
                        }

                        Rectangle {
                            id: selWallName
                            height: parent.height / 6
                            width: parent.width + 5
                            color: Style.warning
                            visible: isSelected ? true : false
                            opacity: isSelected ? 1.0 : 0.0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.Bezier
                                }
                            }

                            InvertedCorner {
                                anchors {
                                    bottom: selWallName.top
                                    right: selWallName.right
                                }
                                rounding: 15
                                z: 2
                                visible: isSelected ? true : false
                                roundingColor: Style.warning
                                rotation: 90
                            }

                            InvertedCorner {
                                anchors {
                                    bottom: selWallName.top
                                    left: selWallName.left
                                }
                                rounding: 15
                                z: 2
                                visible: isSelected ? true : false
                                roundingColor: Style.warning
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
                                color: Style.textOnWarning
                                opacity: isSelected ? 1.0 : 0.0
                                anchors.centerIn: parent

                                text: {
                                    var cleanName = fileName.replace(/\.[^/.]+$/, "");
                                    var maxLength = 20;

                                    if (cleanName.length > maxLength) {
                                        return cleanName.substring(0, maxLength) + "...";
                                    }
                                    return cleanName;
                                }

                                font {
                                    family: Style.family
                                    pixelSize: Style.fontSizeLg
                                    weight: Font.Bold
                                    styleName: "Bold"
                                }

                                transform: Translate {
                                    y: isSelected ? 0 : -200
                                    Behavior on y {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutBack
                                            easing.overshoot: 2
                                        }
                                    }
                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 250
                                    }
                                }
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
                radius: 25
                z: 10

                color: Style.background
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
                    color: Style.warning

                    font {
                        family: Style.family
                        pixelSize: Style.fontSizeLg
                        weight: Font.Bold
                        styleName: "Bold"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}
