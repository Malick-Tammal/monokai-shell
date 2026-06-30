import QtQuick
import qs.theme
import qs.components

Rectangle {
    id: root
    width: 90
    height: 90
    radius: 10
    color: (activeFocus || mouseArea.containsMouse) ? activeColor : ColorEngine.monokai_fusion.gray6
    border.color: (activeFocus || mouseArea.containsMouse) ? activeBorderColor : ColorEngine.monokai_fusion.gray4
    KeyNavigation.left: prevItem
    KeyNavigation.right: nextItem

    property Item nextItem: null
    property Item prevItem: null
    property color activeColor: null
    property color activeBorderColor: null
    property string iconName: ""
    property color iconColor: null
    property color activeIconColor: null

    signal activated

    Behavior on color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.Bezier
        }
    }

    Keys.onPressed: event => {
        if (event.text === "h" || event.key === Qt.Key_Left) {
            if (prevItem) {
                prevItem.forceActiveFocus();
                event.accepted = true;
            }
        } else if (event.text === "l" || event.key === Qt.Key_Right) {
            if (nextItem) {
                nextItem.forceActiveFocus();
                event.accepted = true;
            }
        } else if (event.text === "k" || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.activated();
            event.accepted = true;
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.forceActiveFocus();
            root.activated();
        }
    }

    Symbols {
        icon: root.iconName
        size: 30
        anchors.centerIn: parent
        iconColor: (root.activeFocus || mouseArea.containsMouse) ? root.activeIconColor : root.iconColor
        weight: Font.Bold
    }
}
