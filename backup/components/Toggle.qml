import "../globals"
import QtQuick
import ".."

Rectangle {
    id: toggle
    width: 44
    height: 24
    radius: 12
    property bool checked: false
    signal toggled(bool state)

    color: checked ? Config.accent : "#363a4f"

    // The White Circle
    Rectangle {
        width: 20
        height: 20
        radius: 10
        y: 2
        x: toggle.checked ? 22 : 2
        color: "white"

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuint
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggle.checked = !toggle.checked;
            toggle.toggled(toggle.checked);
        }
    }
}
