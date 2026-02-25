import QtQuick
import "../../../components/"
import qs.theme

Rectangle {
    id: root
    width: 80
    height: 80
    radius: 10
    color: (activeFocus || hoverHandler.hovered) ? activeColor : Style.gray6
    border.color: (activeFocus || hoverHandler.hovered) ? activeBorderColor : Style.gray4
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

    HoverHandler {
        id: hoverHandler
    }

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
        size: 25
        anchors.centerIn: parent
        iconColor: (root.activeFocus || hoverHandler.hovered) ? root.activeIconColor : root.iconColor
    }
}
