pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    function parse(text) {
        let jsonStr = text;
        jsonStr = jsonStr.replace(/\/\/.*/g, '');
        jsonStr = jsonStr.replace(/\/\*[\s\S]*?\*\//g, '');
            jsonStr = jsonStr.replace(/,(\s*[}\]])/g, '$1');
        return JSON.parse(jsonStr);
    }
}
