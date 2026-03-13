import QtQuick
import Quickshell.Wayland
import qs.theme

Rectangle {
    id: root

    property var windowData: null
    property var toplevel: null
    property real scaleFactor: 2.0
    property bool isActive: false
    property bool _hovered: false

    signal clicked()

    width: (windowData ? windowData.size[0] : 100) * scaleFactor
    height: (windowData ? windowData.size[1] : 100) * scaleFactor

    radius: 8
    color: Style.dark4
    border.color: root.isActive
        ? (root._hovered ? Style.green4 : Style.green5)
        : (root._hovered ? Style.gray4 : Style.dark2)
    border.width: root.isActive ? 2 : 1
    antialiasing: true

    clip: true
    layer.enabled: screencopy.hasContent

    scale: root._hovered ? 1.02 : 1.0
    z: root._hovered ? 10 : (root.isActive ? 5 : 0)

    Behavior on scale {
        NumberAnimation { duration: 250; easing.type: Easing.OutBack }
    }

    ScreencopyView {
        id: screencopy
        anchors.fill: parent
        captureSource: root.toplevel
        live: true
        paintCursor: false

        // Maintain original aspect ratio but constrain within the window card
        constraintSize: Qt.size(parent.width, parent.height)
    }

    // Window class icon (nerd font)
    Text {
        id: classIcon

        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10
        visible: !screencopy.hasContent

        text: {
            if (!root.windowData) return "";
            var cls = root.windowData.class.toLowerCase();
            if (cls.indexOf("firefox") >= 0) return "\uf269";
            if (cls.indexOf("chrome") >= 0 || cls.indexOf("chromium") >= 0) return "\uf268";
            if (cls.indexOf("code") >= 0 || cls.indexOf("vscode") >= 0) return "\ue70c";
            if (cls.indexOf("terminal") >= 0 || cls.indexOf("kitty") >= 0 || cls.indexOf("alacritty") >= 0 || cls.indexOf("foot") >= 0 || cls.indexOf("wezterm") >= 0) return "\uf120";
            if (cls.indexOf("discord") >= 0) return "\uf392";
            if (cls.indexOf("spotify") >= 0) return "\uf1bc";
            if (cls.indexOf("thunar") >= 0 || cls.indexOf("nautilus") >= 0 || cls.indexOf("files") >= 0) return "\uf07b";
            if (cls.indexOf("steam") >= 0) return "\uf1b6";
            if (cls.indexOf("telegram") >= 0) return "\uf2c6";
            if (cls.indexOf("obsidian") >= 0) return "\ue7a8";
            return "\uf2d0";
        }

        font.family: Style.nerdFamily
        font.pixelSize: Math.min(root.width * 0.3, root.height * 0.3, 32)
        color: root.isActive ? Style.green5 : Style.gray2
    }

    // Window title
    Text {
        id: titleLabel

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: classIcon.bottom
        anchors.topMargin: 4
        visible: !screencopy.hasContent

        width: parent.width - 12

        text: root.windowData ? root.windowData.title : ""
        font.family: Style.family
        font.pixelSize: Style.fontSizeXs
        color: Style.gray2
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 1
    }

    // Window class label (bottom)
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        visible: !screencopy.hasContent

        width: parent.width - 12

        text: root.windowData ? root.windowData.class : ""
        font.family: Style.family
        font.pixelSize: 8
        color: Style.dark1
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 1
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: root.clicked()
        onEntered: root._hovered = true
        onExited: root._hovered = false
    }

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
}
