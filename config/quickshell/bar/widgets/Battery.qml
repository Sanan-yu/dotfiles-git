// Battery.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Hyprland
import qs.theming
import qs.components.reusable

Item {
	id: root
	implicitWidth: 100
	// Using parent caused crashes sometimes
	implicitHeight: Dimensions.barHeight

	// setting battery once to use everywhere
	readonly property var battery: UPower.displayDevice
	readonly property real percentage: battery.isLaptopBattery && battery.ready ? battery.percentage : 0

	readonly property bool isAC: battery.state === UPowerDeviceState.Charging
	readonly property bool isFull: battery.state === UPowerDeviceState.FullyCharged
	readonly property bool isOnBattery: battery.state === UPowerDeviceState.Discharging
	property real health: battery.healthSupported ? battery.healthPercentage : 0

	// Calculation function(be careful, it's not quite accurate: I am limited with technologies of my time.)
	function formatTime(seconds) {
		if (seconds <= 0) return "Calculating..."
		let h = Math.floor(seconds / 3600)
		let m = Math.floor((seconds % 3600) / 60)
		return h > 0 ? `${h}h ${m}m` : `${m}m`
	}

	// finding battery's health as quickshell doesn't seem to work
	Process {
		id: healthCheck
		command: ["sh", "-c", "upower -i $(upower -e | grep 'BAT') | grep 'capacity' | awk '{print $2}' | tail -1"]
		running: true
		stdout: StdioCollector {
			onStreamFinished: () => {
				root.health = parseInt(text.replace("%", ""));
				console.log("health check:", text);
			}
		}
	}

	Timer {
		interval:600000 // Refresh every 10 minutes (10 * 60 * 1000)
		running: true
		repeat: true
		onTriggered: healthCheck.running = true
	}

	// Bar visual
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onClicked: {
			var pos = root.mapToGlobal(Qt.point(0, 0))
			batteryPopup.anchor.rect.x = pos.x + root.width/2 - batteryPopup.implicitWidth/2
			batteryPopup.anchor.rect.y = pos.y + root.height + 5
			batteryPopup.visible = !batteryPopup.visible
			grab.active = batteryPopup.visible
		}

		Rectangle {
			anchors.fill: parent
			color: Colors.surface
			radius: 12 

			// The Fill Level
			Rectangle {
				height: parent.height
				width: parent.width * root.percentage
				radius: parent.radius

				// MD3 Logic: Low -> Error (Red); Charging/On Battery -> Secondary (Aqua/Mint)
				color: root.percentage < 0.2 
				? Colors.error 
				: Colors.secondary
				opacity: 0.85

				Behavior on width { NumberAnimation { duration: 800; easing.type: Easing.OutExpo } }
			}

			RowLayout {
				anchors.centerIn: parent
				spacing: 6
				Text {
					text: root.isAC ? "󱐋" : (root.percentage < 0.2 ? "󰂃" : "󰁹")
					color: Colors.surfaceText
					font.pixelSize: 14
				}
				Text {
					text: Math.round(root.percentage * 100) + "%"
					color: Colors.surfaceText
					font.bold: true
					font.pixelSize: 13
				}
			}
		}
	}

	// --- THE MD3 POPUP ---
	PopupWindow {
		id: batteryPopup
		visible: false
		implicitWidth: 300
		implicitHeight: 300
		color: "transparent"
		anchor.window: panelBar

		Rectangle {
			anchors.fill: parent
			// MD3: Floating menus or popups should use the baseline surface or container background
			color: Colors.surface
			radius: 28 // Significant MD3 rounding
			border.color: Colors.outlineVariant 
			border.width: 1

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 20
				spacing: 15

				Text {
					text: "Battery Status"
					color: Colors.primary
					font.bold: true
					font.pixelSize: 18
				}

				Rectangle {
					Layout.fillWidth: true
					Layout.preferredHeight: 80
					color: Colors.surfaceContainerHigh 
					radius: 16

					RowLayout {
						anchors.fill: parent
						anchors.margins: 15

						ColumnLayout {
							spacing: 2
							Text { 
								text: root.isAC ? "Power Source" : "Time Remaining"
								color: Colors.surfaceVariantText
								font.pixelSize: 11
							}
							Text { 
								text: root.isAC ? "AC Adapter" : root.formatTime(battery.timeToEmpty)
								color: Colors.surfaceText
								font.bold: true
								font.pixelSize: 16
							}
						}

						// Creating space between components
						Item { Layout.fillWidth: true }

						Text {
							text: Math.round(root.percentage * 100) + "%"
							color: Colors.primary
							font.pixelSize: 24
							font.bold: true
						}
					}
				}

				//Stats Grid(looks awful but Imma fix it)
				GridLayout {
					columns: 2
					Layout.fillWidth: true

					Text { text: "Health:"; color: Colors.surfaceVariantText; font.pixelSize: 12 }
					Text { text: root.health + "%"; color: Colors.surfaceText; Layout.alignment: Qt.AlignRight }

					Text { text: "Energy Rate:"; color: Colors.surfaceVariantText; font.pixelSize: 12 }
					Text { 
						text: battery.changeRate.toFixed(1) + " W"
						color: Colors.surfaceText
						Layout.alignment: Qt.AlignRight 
					}

					Text { text: "State:"; color: Colors.surfaceVariantText; font.pixelSize: 12 }
					Text { 
						text: root.isAC ? "Charging" : "Discharging"
						// Using different colors for sense of urgency
						color: root.isAC ? Colors.secondary : Colors.tertiary
						Layout.alignment: Qt.AlignRight 
					}
				}
			}
		}

		// grabFocus doesn't work for me, I use full version instead
		HyprlandFocusGrab {
			id: grab
			windows: [ batteryPopup ]
			onCleared: batteryPopup.visible = false
		}
	}
}
