import QtQuick
import Quickshell

Rectangle{
	id: root
	height: 30  // defaults
	width: 30

	/* public API */    
	property string fontFamily: "Jetbrains Mono Nerd"
	property real fontSize: 16
	property string text: ""
	property color initialColor
	property color pressedColor
	property color textInitial
	property color textPressed

	signal clicked(mouse: MouseEvent)
	signal entered()
	signal exited()

	property bool pressed: false

	color: pressed ? pressedColor : initialColor

	radius: pressed ? 9 : height / 2

	Text{
		id: text
		anchors.centerIn: parent
		font.family: root.fontFamily
		font.pixelSize: root.fontSize
		text: root.text
		color: root.pressed ? root.textPressed : root.textInitial
	}

	MouseArea {
		acceptedButtons: Qt.AllButtons
		id: area
		anchors.fill: parent
		onClicked: mouse => {
			// if (mouse.button === Qt.LeftButton) {
			// 	root.pressed = !root.pressed 
			// }
			root.clicked(mouse)
		}
		hoverEnabled: true
		onEntered: root.entered()
		onExited: root.exited()
	}
	Behavior on color {
		ColorAnimation { duration: 200 }
	}
	Behavior on radius {
		NumberAnimation { duration: 200; easing.type: Easing.OutBack }
	}
}
