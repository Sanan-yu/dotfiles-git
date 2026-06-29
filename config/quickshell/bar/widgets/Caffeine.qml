// Caffeine.qml

import Quickshell
import Quickshell.Io
import QtQuick
import qs.theming
import qs.components.reusable

// Again using custom component to match MD3 looks
MD3ToggleButton {
	id: caffeineRect
    height: Dimensions.barHeight
	width: height

	text: caffeineRect.pressed ? "󰅶" : "󰾪" 

	Process {
		id: caffeine
		// Sorry, I am too stupid to put all that here...
		command: [ Quickshell.shellDir + "/scripts/caffeine.sh"]
	}

	// MD3 guidelines for filled button component
	initialColor: Colors.surfaceContainer
	pressedColor: Colors.primary

	textInitial: Colors.surfaceVariantText
	textPressed: Colors.primaryText

	onClicked: {
		caffeine.running = true
	}

	Process {
		id: statusCheck
		command: ["pidof", "hypridle"]
		onExited: (code) => {
			caffeineRect.pressed = code == 0 ? false : true
		}
	}

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: {
			statusCheck.running = true
		}
	}

	Behavior on color {
		ColorAnimation { duration: 200 }
	}
	Behavior on radius {
		NumberAnimation { duration: 200; easing.type: Easing.OutBack }
	}
}
