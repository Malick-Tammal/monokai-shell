import QtQuick
import qs.theme
import qs.components

//  INFO: This will need it when we start making the vertical bar

Item {
    id: root
    width: rounding
    height: rounding
    z: 5

    required property Item target
    property color borderColor: Style.surface
    property string position: "top"
    property int rounding: 20
    property bool haveBorder: true

    rotation: {
        if (root.position === "top") {
            rotation: -90;
        } else if (root.position === "bottom") {
            rotation: 180;
        } else if (root.position === "left") {
            rotation: -90;
        }
    }

    anchors.top: {
        if (root.position === "top") {
            root.target.top;
        } else if (root.position === "right" || root.position === "left") {
            root.target.bottom;
        }
    }

    anchors.bottom: {
        if (root.position === "bottom") {
            root.target.bottom;
        }
    }

    anchors.left: {
        if (root.position === "top" || root.position === "bottom") {
            root.target.right;
        } else if (root.position === "left") {
            root.target.left;
        }
    }

    anchors.right: {
        if (root.position === "right") {
            root.target.right;
        }
    }

    anchors.margins: {
        left: root.position === "bottom" ? -1 : 0;
        top: root.position === "left" || root.position === "bottom" ? -1 : 0;
    }

    Inverted {
        rounding: parent.width
        roundingColor: root.borderColor
        visible: root.haveBorder

        transform: Translate {
            x: -1
            y: root.position === "left" ? 1.4 : 0
        }
    }

    Inverted {
        rounding: parent.width
        roundingColor: Style.background

        transform: Translate {
            x: 0
            y: root.position === "left" ? 1 : -1
        }
    }
}
