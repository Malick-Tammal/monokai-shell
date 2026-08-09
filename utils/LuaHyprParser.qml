pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    function parse(obj: var): string {
        let tree = {};

        const LUA_KEYWORDS = new Set(["and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"]);

        for (let key in obj) {
            let val = obj[key];
            let parts = key.split(/[:\.]/);
            let current = tree;

            for (let i = 0; i < parts.length - 1; i++) {
                let part = parts[i];
                if (!current[part] || typeof current[part] !== "object" || Array.isArray(current[part])) {
                    current[part] = {};
                }
                current = current[part];
            }
            current[parts[parts.length - 1]] = val;
        }

        function isValidLuaIdentifier(str) {
            return /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(str) && !LUA_KEYWORDS.has(str);
        }

        function serialize(val, indentLevel) {
            const indent = "  ".repeat(indentLevel);
            const innerIndent = "  ".repeat(indentLevel + 1);

            if (typeof val === "boolean")
                return val ? "true" : "false";
            if (typeof val === "number")
                return Number.isNaN(val) ? "nil" : val.toString();

            if (typeof val === "string") {
                const escaped = val.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
                return `"${escaped}"`;
            }

            if (Array.isArray(val)) {
                let items = val.map(item => serialize(item, indentLevel + 1));
                return `{ ${items.join(", ")} }`;
            }

            if (typeof val === "object" && val !== null) {
                let keys = Object.keys(val);
                if (keys.length === 0)
                    return "{}";

                let fields = [];
                for (let k of keys) {
                    let formattedKey = isValidLuaIdentifier(k) ? k : `["${k}"]`;
                    fields.push(`${innerIndent}${formattedKey} = ${serialize(val[k], indentLevel + 1)}`);
                }
                return `{\n${fields.join(",\n")}\n${indent}}`;
            }

            return "nil";
        }

        return `hl.config(${serialize(tree, 0)})`;
    }
}
