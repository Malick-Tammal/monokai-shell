pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    property bool isActive: false
    property string currentSubmap: ""
    property string themeColor: "gray"
    property string currentIcon: "info"

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap") {
                const submapName = event.data.trim();

                if (submapName === "") {
                    root.isActive = false;
                    root.currentSubmap = "";
                } else {
                    root.currentSubmap = submapName;
                    root.isActive = true;

                    switch (submapName) {
                    case "window":
                        root.themeColor = "yellow";
                        root.currentIcon = "select_window_2";
                        break;
                    case "screenshot":
                        root.themeColor = "purple";
                        root.currentIcon = "screenshot_monitor";
                        break;
                    case "scratchpad":
                        root.themeColor = "orange";
                        root.currentIcon = "layers";
                        break;
                    case "groups":
                        root.themeColor = "green";
                        root.currentIcon = "ad_group";
                        break;
                    case "managers":
                        root.themeColor = "blue";
                        root.currentIcon = "settings_applications";
                        break;
                    case "dev":
                        root.themeColor = "red";
                        root.currentIcon = "code";
                        break;
                    default:
                        root.themeColor = "gray";
                        root.currentIcon = "settings";
                        break;
                    }
                }
            }
        }
    }
}
