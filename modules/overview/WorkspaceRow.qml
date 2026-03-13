import QtQuick
import qs.theme

Item {
    id: root

    property int workspaceId: 0
    property string workspaceName: ""
    property bool isActive: false
    property var windows: []
    property real monitorWidth: 1920
    property real monitorHeight: 1080
    property string focusedAddress: ""
    property var toplevelMap: ({})

    signal windowClicked(string address)

    property real _rowHeight: 500
    property real _scale: _rowHeight / monitorHeight
    property real _contentWidth: {
        if (windows.length === 0) return monitorWidth * _scale;
        var minX = Infinity;
        var maxX = -Infinity;
        for (var i = 0; i < windows.length; i++) {
            var wx = windows[i].at[0];
            var ww = windows[i].size[0];
            if (wx < minX) minX = wx;
            if (wx + ww > maxX) maxX = wx + ww;
        }
        return (maxX - minX) * _scale;
    }
    property real _minX: {
        if (windows.length === 0) return 0;
        var m = Infinity;
        for (var i = 0; i < windows.length; i++) {
            if (windows[i].at[0] < m) m = windows[i].at[0];
        }
        return m;
    }
    property real _minY: {
        if (windows.length === 0) return 0;
        var m = Infinity;
        for (var i = 0; i < windows.length; i++) {
            if (windows[i].at[1] < m) m = windows[i].at[1];
        }
        return m;
    }

    // Find the focused window's center X in content-space for horizontal centering
    property real _focusedContentCenterX: {
        for (var i = 0; i < windows.length; i++) {
            if (windows[i].address === focusedAddress) {
                var wx = (windows[i].at[0] - _minX) * _scale;
                var ww = windows[i].size[0] * _scale;
                return wx + ww / 2;
            }
        }
        // No focused window in this workspace -- center the whole strip
        return _contentWidth / 2;
    }

    height: _rowHeight + workspaceLabel.height + 12

    // Workspace label
    Text {
        id: workspaceLabel

        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top

        text: root.workspaceName || ("Workspace " + root.workspaceId)
        font.family: Style.family
        font.pixelSize: Style.fontSizeSm
        font.bold: root.isActive
        color: root.isActive ? Style.green5 : Style.gray3
    }

    // Active workspace indicator dot
    // Removed to favor background strip highlight

    // Scrollable window strip — horizontally centered on focused window
    Flickable {
        id: flickable

        anchors.top: workspaceLabel.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20

        height: root._rowHeight

        // Add half-viewport padding on each side so any window can reach center
        property real _halfView: flickable.width / 2
        contentWidth: root._contentWidth + flickable.width
        contentHeight: root._rowHeight

        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick

        // Snap to focused window center on load
        Component.onCompleted: {
            flickable.contentX = root._focusedContentCenterX;
        }
        onWidthChanged: {
            flickable.contentX = root._focusedContentCenterX;
        }

        // Background strip
        Rectangle {
            x: flickable._halfView - 8
            y: -8
            width: root._contentWidth + 16
            height: root._rowHeight + 16
            color: root.isActive ? Style.dark2 : Style.dark3
            radius: 12
            opacity: root.isActive ? 0.8 : 0.5
            border.color: root.isActive ? Style.green5 : "transparent"
            border.width: root.isActive ? 2 : 0

            Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on border.width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        }

        // Window cards
        Repeater {
            model: root.windows

            WindowCard {
                required property var modelData

                y: (modelData.at[1] - root._minY) * root._scale
                windowData: modelData
                scaleFactor: root._scale
                isActive: modelData.address === root.focusedAddress
                toplevel: root.toplevelMap[modelData.address] || null

                // Centered layout: half-viewport padding + relative position
                x: flickable._halfView + (modelData.at[0] - root._minX) * root._scale

                onClicked: root.windowClicked(modelData.address)
            }
        }
    }
}
