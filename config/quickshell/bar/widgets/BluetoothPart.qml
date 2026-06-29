// BluetoothPart.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import Qt5Compat.GraphicalEffects
import qs.theming
import qs.components.reusable

Rectangle {
	id: bluetoothRectangle
	height: Dimensions.barHeight
	width: height
	color: Colors.surface
	radius: 9

	Rectangle {
		id: stateLayer
		anchors.fill: parent
		radius: parent.radius
		color: Colors.primary
		opacity: area.containsPress ? 0.12 : (area.containsMouse ? 0.08 : 0.0)
		Behavior on opacity { NumberAnimation { duration: Anims.duration.expressiveSlowEffects; easing.bezierCurve: Anims.easing.expressiveSlowEffects } }
	}

	readonly property var adapter: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter : null
	readonly property bool isEnabled: bluetoothRectangle.adapter ? bluetoothRectangle.adapter.enabled : false
	readonly property bool isDiscovering: bluetoothRectangle.adapter ? bluetoothRectangle.adapter.discovering : false

	Text {
		text: (bluetoothRectangle.isEnabled ? "󰂯" : "󰂲")
		anchors.centerIn: parent
		color: bluetoothRectangle.isEnabled ? Colors.primary : Colors.surfaceText
		font.family: "Material Symbols"
		Behavior on color { ColorAnimation { duration: Anims.mediumDur } }
		rotation: bluetoothRectangle.isDiscovering ? null : 0

		RotationAnimation on rotation {
			running: bluetoothRectangle.isDiscovering
			loops: Animation.Infinite
			from: 0
			to: 360
			duration: 1500
		}
	}

	PopupWindow {
		id: bluetoothPopupWin
		visible: false
		implicitWidth: 400
		implicitHeight: 450
		color: "transparent"
		anchor.window: panelBar

		Rectangle {
			anchors.fill: parent
			color: Colors.surfaceContainerLow
			radius: 28
			border.color: Colors.outlineVariant
			border.width: 1

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 16
				spacing: 8

				// Popup Header
				RowLayout {
					Layout.fillWidth: true
					Layout.preferredHeight: 48
					spacing: 12

					Text {
						text: "Bluetooth"
						font.family: "Roboto"
						font.pixelSize: 22
						color: Colors.surfaceText
						Layout.alignment: Qt.AlignVCenter
					}

					Item { Layout.fillWidth: true }

					// Scan Button (IconButton)
					MD3ToggleButton {
						id: scanButton
						Layout.preferredWidth: 40
						Layout.preferredHeight: 40
						text: "󰊫"
						fontSize: 20
						fontFamily: "Material Symbols"
						initialColor: "transparent"
						pressedColor: Colors.secondaryContainer
						textInitial: Colors.surfaceText
						textPressed: Colors.secondaryContainerText
						pressed: bluetoothRectangle.isDiscovering

						onClicked: {
							if (!bluetoothRectangle.adapter) return;
							bluetoothRectangle.adapter.discovering = !bluetoothRectangle.adapter.discovering;
						}
					}

					// MD3 Switch
					Switch {
						id: control
						checked: bluetoothRectangle.isEnabled
						implicitWidth: 55
						implicitHeight: 32

						onClicked: {
							if (!bluetoothRectangle.adapter) return;
							bluetoothRectangle.adapter.enabled = !bluetoothRectangle.adapter.enabled;
						}

						indicator: Rectangle {
							implicitWidth: 52
							implicitHeight: 32
							radius: height / 2
							color: control.checked ? Colors.primary : Colors.surfaceContainerHighest
							border.color: control.checked ? Colors.primaryText : Colors.outline
							border.width: 1

							Behavior on color { ColorAnimation { duration: 200 } }

							Rectangle {
								id: lil
								x: control.checked ? parent.width - width - 4 : 7
								anchors.verticalCenter: parent.verticalCenter
								width: control.checked ? 24 : 18
								height: width
								radius: width / 2
								color: control.checked ? Colors.primaryText : Colors.outline

								Behavior on x { NumberAnimation { duration: 150; easing.bezierCurve: [0.34, 0.80, 0.34, 1.00]; easing.overshoot: 1.2 } }
								Behavior on width { NumberAnimation { duration: 150 } }

								Image {
									id: checkIcon
									anchors.centerIn: parent
									height: 15
									width: 15 
									sourceSize.height: 15 
									sourceSize.width: 15
									visible: control.checked
									smooth: true
									source: Quickshell.shellPath("assets/check.svg") 
									layer{
										enabled: true
										effect: ColorOverlay{
											color: Colors.primary
										}
									}
								}
							}
						}
					}
				}

				// Subtitle Status Text
				Text {
					Layout.fillWidth: true
					Layout.leftMargin: 16
					Layout.rightMargin: 16
					text: bluetoothRectangle.isEnabled ? (bluetoothRectangle.isDiscovering ? "Searching for devices…" : "Ready to connect") : "Bluetooth is off"
					color: Colors.surfaceVariantText
					font.family: "Roboto"
					font.pixelSize: 14
					elide: Text.ElideRight
				}

				// Devices List
				ListView {
					id: devicesList
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.topMargin: 8
					clip: true
					spacing: 4
					model: (bluetoothRectangle.isEnabled && Bluetooth.devices) ? Bluetooth.devices : []

					delegate: Rectangle {
						id: delegateRoot 
						width: ListView.view ? ListView.view.width : 0
						height: 56
						radius: 16
						color: delegateMouseArea.containsMouse ? Colors.surfaceContainerHigh : "transparent"

						Behavior on color { ColorAnimation { duration: Anims.quickDur } }

						RowLayout {
							anchors.fill: parent
							anchors.leftMargin: 16
							anchors.rightMargin: 8
							spacing: 16

							// Icon Box
							Rectangle {
								Layout.preferredWidth: 40
								Layout.preferredHeight: 40
								Layout.alignment: Qt.AlignVCenter
								color: (modelData && modelData.connected) ? Colors.primaryContainer : Colors.surfaceContainerHighest
								radius: 12

								Text {
									anchors.centerIn: parent
									text: "󰂯"
									font.family: "Material Symbols"
									font.pixelSize: 24
									color: (modelData && modelData.connected) ? Colors.primaryContainerText : Colors.surfaceVariantText
								}
							}

							// Device Info
							ColumnLayout {
								Layout.fillWidth: true
								Layout.alignment: Qt.AlignVCenter
								spacing: 0

								Text {
									Layout.fillWidth: true
									text: modelData ? (modelData.deviceName || modelData.name || "Unknown Device") : ""
									color: Colors.surfaceText
									font.family: "Roboto"
									font.pixelSize: 16
									elide: Text.ElideRight
								}
								Text {
									Layout.fillWidth: true
									text: modelData ? (modelData.connected ? "Connected" : (modelData.paired ? "Saved" : (modelData.pairing ? "Pairing…" : "Not paired"))) : ""
									color: Colors.surfaceVariantText
									font.family: "Roboto"
									font.pixelSize: 12
									elide: Text.ElideRight
								}
							}

							// Battery Indicator
							Rectangle {
								Layout.alignment: Qt.AlignVCenter
								Layout.preferredWidth: 40
								Layout.preferredHeight: 40
								color: "transparent"
								visible: modelData && modelData.batteryAvailable

								Text {
									anchors.centerIn: parent
									font.family: "Material Symbols"
									font.pixelSize: 20
									color: Colors.surfaceVariantText
									property real percent: modelData ? Math.round(modelData.battery * 100) : 0
									text: percent >= 87 ? "󰥈" : percent >= 75 ? "󰥇" : percent >= 62 ? "󰥆" : percent >= 50 ? "󰥅" : percent >= 37 ? "󰥄" : percent >= 25 ? "󰥃" : percent >= 12 ? "󰥂" : "󰥀"
								}
							}
						}

						MouseArea {
							id: delegateMouseArea
							anchors.fill: parent
							hoverEnabled: true
							propagateComposedEvents: true 
							onClicked: (mouse) => {
								if (!modelData) return;
								if (modelData.paired) {
									modelData.connected = !modelData.connected;
								} else {
									modelData.pair();
								}
								mouse.accepted = false;
							}
						}
					}
				}

				// Loading Spinner
				M3Spinner {
					Layout.alignment: Qt.AlignHCenter
					Layout.preferredWidth: 48
					Layout.preferredHeight: 48
					visible: bluetoothRectangle.isDiscovering
				}
			}
		}

		HyprlandFocusGrab {
			id: grab
			windows: [ bluetoothPopupWin ]
			onCleared: bluetoothPopupWin.visible = false;
		}
	}

	MouseArea {
		id: area
		anchors.fill: parent
		acceptedButtons: Qt.AllButtons
		hoverEnabled: true

		onClicked: (mouse) => {
			if (mouse.button === Qt.LeftButton) {
				if (bluetoothRectangle.adapter) {
					bluetoothRectangle.adapter.enabled = !bluetoothRectangle.adapter.enabled
				}
			} else if (mouse.button === Qt.RightButton) {
				var pos = bluetoothRectangle.mapToGlobal(Qt.point(0,0));
				bluetoothPopupWin.anchor.rect.x = pos.x + bluetoothRectangle.width/2 - bluetoothPopupWin.implicitWidth/2;
				bluetoothPopupWin.anchor.rect.y = pos.y + bluetoothRectangle.height + 6;
				bluetoothPopupWin.visible = !bluetoothPopupWin.visible;
				grab.active = bluetoothPopupWin.visible;
			}
		}
	}
}
