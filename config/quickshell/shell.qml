//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick

import "bar"
import "osd"
import "sys"
import "components"

ShellRoot {
	id: root

	Variants {
		model: Quickshell.screens
		delegate: TopBar {
			screen: modelData
		}
	}

	AudioOsd {}
	BrightnessOsd{}
	NotificationOsd{}

	ReloadPopup{}

	Loader {
		id: overviewLoader
		active: false
		sourceComponent: Overview{}
	}
	Loader{
		id: appLauncher
		active: true
		sourceComponent: AppLauncher{}
	}

	IpcHandler {
		target: "overviewLoader"
		function toggleVisible() {
			overviewLoader.active = !overviewLoader.active;
			console.log("IPC: Toggle Overview ->", overviewLoader.active);
		}
	}
}
