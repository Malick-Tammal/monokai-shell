pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool logs: false
    property string theme: "monokai_fusion"  // TIP: (Options) monokai_fusion | matugen
}
