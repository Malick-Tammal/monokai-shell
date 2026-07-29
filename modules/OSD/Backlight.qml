import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.theme
import qs.services
import qs.core
import QtQuick.Layouts

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "backlight-osd"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
    }

    color: "transparent"

    implicitWidth: wrapper.width
    implicitHeight: wrapper.height * 3

    visible: GlobalStates.showBacklightOsd

    Connections {
        target: KbService

        function onBacklightLevelChanged() {
            GlobalStates.showBacklightOsd = true;
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        repeat: false
        onTriggered: {
            GlobalStates.showBacklightOsd = false;
        }
    }

    Rectangle {
        id: wrapper
        width: row.implicitWidth + 2
        height: 65
        color: ColorEngine.monokai_fusion.orange5
        radius: 15

        anchors {
            top: parent.top
            topMargin: (GlobalStates.isBarHovered || GlobalStates.barVisible) ? BarService.barHeight + Style.globalPadding * 2 : Style.globalPadding

            Behavior on topMargin {
                SpringAnimation {
                    spring: 10
                    damping: 0.5
                    mass: 1.5
                }
            }
        }

        RowLayout {
            id: row
            spacing: 0
            height: parent.height - 2
            anchors.centerIn: parent

            Rectangle {
                id: icon
                color: ColorEngine.monokai_fusion.orange5
                width: symbol.width + 35
                height: parent.height
                topLeftRadius: 15
                bottomLeftRadius: 15

                Symbols {
                    id: symbol
                    icon: KbService.symbol
                    size: 26
                    color: ColorEngine.monokai_fusion.orange9
                    anchors.centerIn: parent
                }
            }

            Rectangle {
                id: textIndicator
                color: ColorEngine.monokai_fusion.orange9
                implicitWidth: barsRow.implicitWidth + 30
                height: parent.height
                radius: 15

                RowLayout {
                    id: barsRow
                    spacing: 15
                    anchors.centerIn: parent

                    Rectangle {
                        width: 80
                        height: 10
                        radius: 999
                        color: KbService.backlightLevel >= 1 ? ColorEngine.monokai_fusion.orange2 : ColorEngine.monokai_fusion.orange8

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    Rectangle {
                        width: 80
                        height: 10
                        radius: 999
                        color: KbService.backlightLevel === 2 ? ColorEngine.monokai_fusion.orange2 : ColorEngine.monokai_fusion.orange8

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }
            }
        }
    }
}
