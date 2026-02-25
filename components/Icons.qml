import QtQuick

Image {
    id: icon

    property string path: ""
    property int size: 0

    source: path

    width: size
    height: size
    sourceSize.width: size
    sourceSize.height: size

    smooth: false
    antialiasing: false
    cache: false
    asynchronous: false
}
