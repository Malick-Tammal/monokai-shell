import Quickshell
import Quickshell.Wayland
import QtQuick
import "./modules/"
import qs.services

PanelWindow {
    id: root
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
            if (root.screen.name === targetScreenName) {
                console.log("[Bar] Toggling visibility for screen: " + root.screen.name);
                root.isVisible = !root.isVisible;
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
            barWindowId: root
        }
        Left {}
    }
}
