import Quickshell
import Quickshell.Wayland
import QtQuick
import "./modules/"
import qs.services

PanelWindow {
    id: bar
    color: "transparent"
    implicitHeight: 42
    visible: isVisible

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "bar"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        left: 10
        right: 10
        top: 10
    }

    property bool isVisible: true

    Connections {
        target: BarService

        function onToggleRequested(targetScreenName) {
            if (bar.screen.name === targetScreenName) {
                console.log("[Bar] Toggling visibility for screen: " + bar.screen.name);
                bar.isVisible = !bar.isVisible;
            }
        }
    }

    Item {
        id: container
        anchors.bottomMargin: 1
        anchors.topMargin: 1
        anchors.fill: parent

        Center {}
        Right {
            barWindowId: bar
        }
        Left {}
    }
}
