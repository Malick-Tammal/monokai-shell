import Quickshell
import QtQuick
import "../../../theme/"
import "../../../components/"

Item {
    id: cornor
    width: rounding
    height: rounding
    z: 5

    required property Item target
    property color borderColor: Style.dark4
    property string position: "top"
    property int rounding: 20
    property bool haveBorder: true

    rotation: {
        if (cornor.position === "top") {
            rotation: -90;
        } else if (cornor.position === "bottom") {
            rotation: 180;
        } else if (cornor.position === "left") {
            rotation: -90;
        }
    }

    anchors.top: {
        if (cornor.position === "top") {
            cornor.target.top;
        } else if (cornor.position === "right" || cornor.position === "left") {
            cornor.target.bottom;
        }
    }

    anchors.bottom: {
        if (cornor.position === "bottom") {
            cornor.target.bottom;
        }
    }

    anchors.left: {
        if (cornor.position === "top" || cornor.position === "bottom") {
            cornor.target.right;
        } else if (cornor.position === "left") {
            cornor.target.left;
        }
    }

    anchors.right: {
        if (cornor.position === "right") {
            cornor.target.right;
        }
    }

    anchors.margins: {
        left: cornor.position === "bottom" ? -1 : 0;
        top: cornor.position === "left" || cornor.position === "bottom" ? -1 : 0;
    }

    Inverted {
        rounding: parent.width
        roundingColor: cornor.borderColor
        visible: cornor.haveBorder

        transform: Translate {
            x: -1
            y: cornor.position === "left" ? 1.4 : 0
        }
    }

    Inverted {
        rounding: parent.width
        roundingColor: Style.bg

        transform: Translate {
            x: 0
            y: cornor.position === "left" ? 1 : -1
        }
    }
}
