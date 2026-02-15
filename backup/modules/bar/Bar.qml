import Quickshell
import QtQuick
import "./components/"

PanelWindow {
    color: "#1D1E19"
    width: 35

    anchors {
        top: true
        bottom: true
        left: true
    }

    Rectangle {
        width: 1
        height: parent.height
        color: "#3E3C3F"
        anchors.right: parent.right
        anchors.top: parent.top
    }

    Workspaces {
        anchors.topMargin: 10
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Battery {
        anchors.bottomMargin: 70
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Clock {
        anchors.bottomMargin: 10
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
