import QtQuick
import "../../../theme/"
import "../../../components/"

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
    property string assetsPath: "../../../assets/"

    readonly property bool showActiveIcon: activeFocus || hoverHandler.hovered

    signal activated

    QtObject {
        id: states
        property string normalIcon: `${root.assetsPath}/icons/normal/${root.iconName}.svg`
        property string activeIcon: `${root.assetsPath}/icons/active/${root.iconName}.svg`
    }

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

    Icon {
        path: states.normalIcon
        size: 25
        visible: !root.showActiveIcon
        anchors.centerIn: parent
    }

    Icon {
        path: states.activeIcon
        size: hoverHandler.hovered ? 28 : 25
        visible: root.showActiveIcon && states.activeIcon !== ""
        anchors.centerIn: parent
        Behavior on size {
            NumberAnimation {
                duration: 100
                easing.type: Easing.Bezier
            }
        }
    }
}
