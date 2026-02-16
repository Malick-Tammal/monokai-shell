import QtQuick
import Quickshell.Io

Process {
    id: notifyProc

    function send(title, body, iconPath): void {
        var args = ["notify-send"];

        if (iconPath && iconPath !== "") {
            args.push("-i", iconPath);
        }

        args.push(title);
        args.push(body);

        if (running)
            running = false;
        command = args;
        running = true;
    }
}
