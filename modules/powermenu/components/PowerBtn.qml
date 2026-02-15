import QtQuick

Rectangle {
    id: root
    width: 80
    height: 80
    radius: 10
    color: (activeFocus || hoverHandler.hovered) ? activeColor : "#33342B"
    scale: hoverHandler.hovered ? 1.03 : 1.0
    KeyNavigation.left: prevItem
    KeyNavigation.right: nextItem

    property Item nextItem: null
    property Item prevItem: null
    property color activeColor: "#5e6050"
    property string iconName: ""
    property string assetsPath: "../../../assets/"

    signal activated

    QtObject {
        id: internal
        property string normalIcon: `${root.assetsPath}/icons/normal/${root.iconName}.svg`
        property string activeIcon: `${root.assetsPath}/icons/active/${root.iconName}.svg`
    }

    HoverHandler {
        id: hoverHandler
    }

    Behavior on color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.OutQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutBack
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

    Image {
        source: root.activeFocus && internal.activeIcon !== "" || hoverHandler.hovered ? internal.activeIcon : internal.normalIcon
        width: 25
        height: 25
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        smooth: false
        antialiasing: true
    }
}
