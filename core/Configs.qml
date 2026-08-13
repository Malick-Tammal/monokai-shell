pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool logs: false

    property bool autoGenColors: false
    property string theme: "monokai-fusion"

    property int dockIconSize: 57
    property bool tintedDockIcons: true

    property bool enableELK: true
    property bool syncELKWithBrightness: true
    property bool syncELKWithMatugen: true
}
