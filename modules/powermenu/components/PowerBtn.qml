import QtQuick
import "../../../theme/"

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
    property color hoverColor: Qt.lighter(activeColor, 1.1)
    property string iconName: ""
    property string assetsPath: "../../../assets/"

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.hoverColor
        opacity: hoverHandler.hovered ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }
        }
    }

    readonly property bool showActiveIcon: activeFocus || hoverHandler.hovered

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

    Item {
        width: 25
        height: 25
        anchors.centerIn: parent

        //  INFO: Normal Icon
        Image {
            anchors.fill: parent
            source: internal.normalIcon

            sourceSize.width: 25
            sourceSize.height: 25

            visible: !root.showActiveIcon

            smooth: false
            antialiasing: false
            fillMode: Image.PreserveAspectFit
        }

        //  INFO: Active/Hover Icon
        Image {
            anchors.fill: parent
            source: internal.activeIcon

            sourceSize.width: 25
            sourceSize.height: 25

            visible: root.showActiveIcon && internal.activeIcon !== ""

            smooth: false
            antialiasing: false
            fillMode: Image.PreserveAspectFit
        }
    }
}
