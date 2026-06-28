pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import "../"

Singleton {
    id: root

    // --- Global Session State ---
    property bool locked: false
    property int pinLength: 10
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    // --- Automatically trigger auth when PIN matches length ---
    onCurrentTextChanged: {
        showFailure = false;

        if (pinLength > 0 && currentText.length === pinLength && !unlockInProgress) {
            tryUnlock();
        }
    }

    function tryUnlock() {
        if (currentText === "") return;

        root.unlockInProgress = true;
        pam.start();
    }

    // --- IPC Actions ---
    IpcHandler {
        target: "lockscreen"
        function lock(): void {
            root.locked = true;
        }
    }

    // --- PAM Authentication Engine ---
    PamContext {
        id: pam

        configDirectory: "pam"
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.locked = false;
                root.currentText = "";
            } else {
                root.currentText = "";
                root.showFailure = true;
            }

            root.unlockInProgress = false;
        }
    }
}
