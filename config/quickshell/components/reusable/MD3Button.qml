import QtQuick
import Quickshell

Rectangle {
    id: root
    height: 30
    width: 30
    radius: 9

    /* public API */    
    property string fontFamily: "Google Sans Code NF"
    property real fontSize: 16
    property string text: ""
    property color initialColor: "#3c3836" // Example defaults
    property color pressedColor: "#a7c080"
    property color textInitial: "#dbd3bc"
    property color textPressed: "#2d353b"
    
    signal clicked()
    signal entered()
    signal exited()

    // We'll use this internal bool to drive the visual state
    property bool isVisualPressed: false

    // Use a conditional binding for the color instead of manual assignment
    color: isVisualPressed ? pressedColor : initialColor

    Text {
        id: buttonText
        anchors.centerIn: parent
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
        text: root.text
        // Drive text color from the same visual state
        color: root.isVisualPressed ? root.textPressed : root.textInitial
        
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Timer {
        id: colorMagic
        interval: 500
        repeat: false
        onTriggered: root.isVisualPressed = false
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            root.isVisualPressed = true
            root.clicked()
            colorMagic.restart() // restart() handles both starting and resetting if clicked rapidly
        }
        
        onEntered: root.entered()
        onExited: root.exited()
    }

    Behavior on color {
        ColorAnimation { duration: 200 }
    }
}
