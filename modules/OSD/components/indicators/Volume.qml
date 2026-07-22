import QtQuick
import Quickshell
import qs.services
import qs.theme
import qs.core
import "../"

Item {
    id: root

    width: slider.width
    height: slider.height

    // property bool shouldShow: GlobalStates.osd

    Slider {
        id: slider
        // state: shouldShow ? "visible" : "hidden"

        // transform: Translate {
        //     id: translate
        // }

        // states: [
        // State {
        //     name: "visible"
        //     PropertyChanges { target: translate; x: 0 }
        // },
        // State {
        //     name: "hidden"
        //     PropertyChanges { target: translate; x: -(root.width + Style.globalPadding) }
        // }
        // ]
        //
        // transitions: [
        // Transition{
        //     to: "visible"
        //     NumberAnimation { target: translate; property: "x"; duration: 100; easing.type: Easing.OutBack }
        // },
        // Transition{
        //     to: "hidden"
        //     NumberAnimation { target: translate; property: "x"; duration: 100; easing.type: Easing.OutBack }
        // }
        // ]

        icon: Audio.symbol
        surface: Style.textOnSuccess
        color: Style.success
        text: Style.textOnSuccess
        value: Audio.volume
    }
}
