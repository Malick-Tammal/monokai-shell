pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool logs: false
    property bool autoGenColors: false
    property string theme: "monokai-fusion"
}
