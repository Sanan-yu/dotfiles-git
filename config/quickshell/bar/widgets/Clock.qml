// Clock.qml
import QtQuick
import Quickshell
import qs.theming

Rectangle {
    id: clockRectangle
    width: clockText.implicitWidth + 24
    height: Dimensions.barHeight
    color: Colors.surface
    radius: height / 2

    SystemClock { id: clock }

    property var formats: [
        { fmt: "hh:mm", color: Colors.surfaceText },
        { fmt: "hh:mm:ss", color: Colors.primary },
        { fmt: "dddd, MMMM d hh:mm", color: Colors.surfaceText }
    ]

    property int variantIndex: 0

    Rectangle {
        id: stateLayer
        anchors.fill: parent
        radius: parent.radius
        color: Colors.surfaceText
        opacity: mouseArea.containsPress ? 0.12 : (mouseArea.containsMouse ? 0.08 : 0.0)
        
        Behavior on opacity { 
            NumberAnimation { duration: Anims.duration.expressiveFastEffects; easing.bezierCurve: Anims.easing.expressiveFastEffects } 
        }
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, clockRectangle.formats[clockRectangle.variantIndex].fmt)
        color: clockRectangle.formats[clockRectangle.variantIndex].color
        font.family: "Google Sans Flex"
        font.pixelSize: 15
        font.weight: Font.Medium
        
        Behavior on color { ColorAnimation { duration: Anims.mediumDur } }
        
        scale: mouseArea.containsPress ? 0.95 : 1.0
        Behavior on scale { 
            SpringAnimation { spring: 3; damping: 0.4; epsilon: 0.05 } 
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            clockRectangle.variantIndex = (clockRectangle.variantIndex + 1) % clockRectangle.formats.length
        }
    }

    Behavior on width {
        SpringAnimation { 
            spring: 3 
            damping: 0.35 
            epsilon: 0.05 
        }
    }
}
