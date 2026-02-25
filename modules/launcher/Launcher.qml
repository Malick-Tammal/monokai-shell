import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import qs.theme

PanelWindow {
    id: window

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "walli"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    property string query: ""

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"

    Shortcut {
        sequences: ["Escape", "Backspace", "q"]
        onActivated: {
            window.visible = false;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: window.visible = false
    }

    function launchSelected() {
        if (list.currentItem && list.currentItem.modelData) {
            list.currentItem.modelData.execute();
            window.visible = false;
        }
    }

    Rectangle {
        width: 700
        height: 600
        anchors.centerIn: parent
        color: Style.bg

        ScriptModel {
            id: filtered
            values: {
                const allEntries = [...DesktopEntries.applications.values];
                const q = window.query.trim();

                if (q === "") {
                    return allEntries;
                } else {
                    return allEntries.filter(d => {
                        return d.name && d.name.toLowerCase().includes(q);
                    });
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                print(filtered.values.map(v => {
                    return v.name;
                }));
            }
        }

        ListView {
            id: list
            anchors.fill: parent
            clip: true
            model: filtered.values
            // currentIndex: filtered.values.length > 0 ? 0 : -1
            orientation: ListView.Vertical
            keyNavigationWraps: true
            preferredHighlightBegin: 0
            preferredHighlightEnd: height
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 80
            highlight: Rectangle {
                radius: 4
                opacity: 1
                color: Style.dark5
            }
            snapMode: ListView.SnapToItem
            boundsBehavior: Flickable.StopAtBounds
            focus: true

            Keys.onPressed: event => {
                const ctrl = event.modifiers & Qt.ControlModifier;
                if (event.key == Qt.Key_Up || event.key == Qt.Key_K && ctrl) {
                    list.decrementCurrentIndex();
                    event.accepted = true;
                } else if (event.key == Qt.Key_Down || event.key == Qt.Key_J && ctrl) {
                    list.incrementCurrentIndex();
                    event.accepted = true;
                } else if ([Qt.Key_Return, Qt.Key_Enter].includes(event.key) || event.key == Qt.Key_L && ctrl) {
                    event.accepted = true;
                    print("malick");
                    window.launchSelected();
                }
            }

            delegate: Item {
                id: entry
                required property var modelData
                required property int index
                width: ListView.view.width
                height: 46

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10

                    IconImage {
                        source: Quickshell.iconPath(modelData.icon, true)
                        width: 23
                        height: 23
                    }

                    Text {
                        id: label
                        color: "white"
                        text: modelData.name
                        font.pointSize: 13
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
