import QtQuick

Rectangle {
	id: slider

	width: 200
	height: 56   // MD3 media height

	/* API */
	property real value: 0.0        // 0..1
	property bool pressed: false
	property bool playing: false
	color: "transparent"

	signal moved(real value)
	signal released(real value)

	/* MD3 tokens */
	property real trackHeight: 4
	property real thumbWidth: 4
	property real thumbHeight: 40
	property real thumbRadius: thumbHeight / 2

	property real leftTrackMargin: 6
	property real rightTrackMargin: 6

	property color leftTrackColor: "#c9abff"
	property color rightTrackColor: "#3e3e51"
	property color thumbColor: "#c9abff"

	/* wave */
	property real waveAmplitude: 1
	property real waveFrequency: 5
	property real wavePhase: 0

	readonly property real usableWidth: width - thumbWidth
	readonly property real thumbCenterX: thumb.x + thumb.width / 2
	Rectangle{
		id: leftTrackRect
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		width: Math.max(slider.thumbCenterX - slider.leftTrackMargin, 0)
		height: slider.trackHeight
		visible: !slider.playing
		color: slider.leftTrackColor
	}

	/* LEFT TRACK — WAVE */
	ShaderEffect {
		id: leftTrack
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		width: Math.max(slider.thumbCenterX - slider.leftTrackMargin, 0)
		height: parent.height
		property real uWidth: width // <--- Pass the pixel width here
		visible: slider.playing

		// Properties must match the 'buf' block in the .frag file exactly
		property color uColor: slider.leftTrackColor
		property real uAmp: slider.waveAmplitude / height * 2
		property real uFreq: slider.waveFrequency
		property real uPhase: slider.wavePhase
		property real uTrackHeight: slider.trackHeight / height
		// Point to the compiled .qsb file
		fragmentShader: "wave.frag.qsb"
		vertexShader: "wave.vert.qsb"
	}

	/* RIGHT TRACK — STRAIGHT */
	Rectangle {
		anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right

		width: Math.max(
			parent.width - (slider.thumbCenterX + slider.rightTrackMargin),
			0
		)
		height: slider.trackHeight
		radius: slider.trackHeight / 2
		color: slider.rightTrackColor
	}

	/* THUMB */
	Rectangle {
		id: thumb
		width: slider.thumbWidth
		height: slider.thumbHeight
		radius: slider.thumbRadius
		color: slider.thumbColor

		y: parent.height / 2 - height / 2
		x: slider.value * slider.usableWidth

		Behavior on x {
			NumberAnimation {
				duration: slider.pressed ? 0 : 160
				easing.type: Easing.OutQuad
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
			updateValue(mouse.x)
			thumb.height = slider.thumbHeight + 6
		}

		onPositionChanged: (mouse) => {
			if (pressed)
			updateValue(mouse.x)
		}

		onReleased: {
			slider.pressed = false
			thumb.height = slider.thumbHeight
			slider.released(slider.value)
		}
	}

	/* WAVE ANIMATION */
	NumberAnimation on wavePhase {
		running: slider.playing
		from: 0
		to: Math.PI * 2 
		loops: Animation.Infinite
		duration: 3000
	}

	function updateValue(px) {
		let v = (px - slider.thumbWidth / 2) / slider.usableWidth
		slider.value = Math.max(0, Math.min(1, v))
		slider.moved(slider.value)
	}
}
