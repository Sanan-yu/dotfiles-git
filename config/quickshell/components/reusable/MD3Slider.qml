import QtQuick

Rectangle {
    id: slider

    width: 100  // defaults
    height: 50 
    color: "transparent"

    /* public API */
    property real value: 0.0    // from 0 to 1
    property bool pressed: false

    signal moved(real value)
    signal released(real value)

    property real trackHeight: 4
    property real thumbWidth: 4      // recommended
    property real thumbHeight: 50
    property real trackRadius: 3
    property color thumbColor: "#ffffff"
    property color leftTrackColor: "#ffffff"
    property color rightTrackColor: "#000000"
    property real leftTrackMargin: 4
    property real rightTrackMargin: 4
    property real thumbRadius: 9
    property real trackSideRadius: 9

    onPressedChanged: {
        thumb.height = pressed ? slider.thumbHeight + 6 : slider.thumbHeight
    }

    Rectangle {
        id: activeTrack
        anchors.left: parent.left
        anchors.verticalCenter: track.verticalCenter
        height: slider.trackHeight
        topRightRadius: slider.trackRadius
        bottomRightRadius: slider.trackRadius
        topLeftRadius: slider.trackSideRadius
        bottomLeftRadius: slider.trackSideRadius
        width: Math.max(thumb.x - slider.leftTrackMargin, 0)
        color: slider.leftTrackColor
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: Math.max(parent.width - (thumb.x + thumb.width + slider.rightTrackMargin), 0)
        height: slider.trackHeight
        topLeftRadius: slider.trackRadius
        bottomLeftRadius: slider.trackRadius
        topRightRadius: slider.trackSideRadius
        bottomRightRadius: slider.trackSideRadius
        color: slider.rightTrackColor
    }

    Rectangle {
        id: thumb
        width: slider.thumbWidth
        height: slider.thumbHeight
        radius: slider.thumbRadius
        color: slider.thumbColor

        y: track.y + track.height / 2 - height / 2
        x: slider.value * (slider.width - width)

        Behavior on x {
            NumberAnimation {
                duration: slider.pressed ? 0 : 160
                easing.type: Easing.OutExpo
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutBack
                easing.overshoot: 1.15
            }
        }
    }

    /* INPUT */
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onPressed: (mouse) => {
            slider.pressed = true
            slider.updateValue(mouse.x)
        }

        onPositionChanged: (mouse) => {
            if (pressed)
            slider.updateValue(mouse.x)
        }

        onReleased: {
            slider.pressed = false
            slider.released(slider.value)
        }
    }

    function updateValue(px) {
        let usable = slider.width - slider.thumbWidth
        let v = (px - slider.thumbWidth / 2) / usable
        slider.value = Math.max(0, Math.min(1, v))
        slider.moved(slider.value)
    }
}
