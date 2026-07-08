pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.theme
import qs.services

Singleton {
    id: root

    enum Edge {
        Top,
        Bottom,
        Left,
        Right
    }

    property int edgeOffset: 3

    function shouldHide(screen, edgeType, componentWidth, componentHeight, componentPadding) {
        if (!screen || !Hypr.windowList || Hypr.windowList.length === 0) return false;

        const screenX = screen.x;
        const screenY = screen.y;
        const screenWidth = screen.width;
        const screenHeight = screen.height;

        const activeWinWs = Hyprland.activeToplevel?.workspace;
        const activeSpecialWsName = (activeWinWs && activeWinWs.name.indexOf("special:") !== -1) ? activeWinWs.name : "";
        const currentNormalWsId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1;

        let boundaryEdge = 0;
        const totalPadding = componentPadding + root.edgeOffset;

        switch (edgeType) {
            case Intellihide.Edge.Bottom:
            boundaryEdge = (screenY + screenHeight) - componentHeight - totalPadding
            break;
            case Intellihide.Edge.Top:
            boundaryEdge = (screenY + componentHeight) + componentHeight
            break;
            case Intellihide.Edge.Right:
            boundaryEdge = (screenX + screenWidth) - componentWidth - totalPadding;
            break;
            case Intellihide.Edge.Left:
            boundaryEdge = screenX + componentWidth + totalPadding;
            break;
        }

        return Hypr.windowList.some(win => {
                if (win.at[0] === -32000 || win.mapped === false || win.hidden === true)
                return false;

                const winIsSpecial = (win.workspace.name && win.workspace.name.indexOf("special:") !== -1) || win.workspace.id < 0;
                if (activeSpecialWsName !== "") {
                    if (win.workspace.name !== activeSpecialWsName)
                    return false;
                } else {
                    if (winIsSpecial || win.workspace.id !== currentNormalWsId)
                    return false;
                }

                if (win.fullscreen)
                return true;

                switch (edgeType) {
                    case Intellihide.Edge.Bottom:
                    const winBottomEdge = win.at[1] + win.size[1];
                    return winBottomEdge > boundaryEdge;

                    case Intellihide.Edge.Top:
                    const winTopEdge = win.at[1];
                    return winTopEdge < boundaryEdge;

                    case Intellihide.Edge.Right:
                    const winRightEdge = win.at[0] + win.size[0];
                    return winRightEdge > boundaryEdge;

                    case Intellihide.Edge.Left:
                    const winLeftEdge = win.at[0];
                    return winLeftEdge < boundaryEdge;
                }

                return false;
        });
    }

}
