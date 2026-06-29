import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.theming 

Scope {
	id: root
	property bool failed: false
	property string errorString: ""

	Connections {
		target: Quickshell

		function onReloadCompleted() {
			Quickshell.inhibitReloadPopup();
			root.failed = false;
			root.errorString = "";
			popupLoader.active = false;
			popupLoader.active = true;
		}

		function onReloadFailed(error) {
			Quickshell.inhibitReloadPopup();
			root.failed = true;
			root.errorString = error;
			popupLoader.active = false;
			popupLoader.active = true; 
		}
	}

	Process {
		id: copy
		command: ["wl-copy", root.errorString]
	}

	LazyLoader {
		id: popupLoader
		active: false

		component:PanelWindow {
			id: popup
			anchors { top: true; left: true }

			margins { 
				top: Dimensions.barHeight + 15; 
				left: 15 
			}

			implicitWidth: rect.width
			implicitHeight: rect.height
			color: "transparent"

			Rectangle {
				id: rect

				color: root.failed ? "#E63C3836" : "#E42D353B" 
				radius: 12
				border.color: root.failed ? Colors.fallbackError : Colors.primary
				border.width: 1

				implicitHeight: layout.implicitHeight + 30
				implicitWidth: Math.min(550, Math.max(320, layout.implicitWidth + 40))

				MouseArea {
					id: mouseArea
					anchors.fill: parent
					hoverEnabled: true
					onClicked: popupLoader.active = false
				}

				ColumnLayout {
					id: layout
					anchors.centerIn: parent
					width: parent.width - 30
					spacing: 12

					RowLayout {
						Layout.fillWidth: true
						spacing: 15

						Text {
							text: root.failed ? "󰚌  Reload Failed" : "󰄬  Reloaded!"
							color: root.failed ? Colors.error : Colors.primary
							font.bold: true
							font.pixelSize: 15
						}

						Item { Layout.fillWidth: true }

						Button {
							id: copyButton
							visible: root.failed
							text: "󰆏 Copy"
							flat: true
							background: Rectangle{
								color: "transparent"
							}
							contentItem: Text {
								text: copyButton.text
								color: copyButton.hovered ? Colors.primary : Colors.surfaceText
								font.pixelSize: 12
								font.bold: true
							}
							onClicked: copy.running = true
						}

						Button {
							id: closeButton
							text: " Close"
							flat: true
							contentItem: Text {
								text: closeButton.text
								color: closeButton.hovered ? Colors.primary : Colors.surfaceText
								font.pixelSize: 12
								font.bold: true
							}

							background: Rectangle{
								color: "transparent"
							}
							onClicked: popupLoader.active = false
						}
					}

					Text {
						text: root.errorString
						color: Colors.surfaceText
						font.family: "JetBrains Mono"
						font.pixelSize: 12
						wrapMode: Text.Wrap
						Layout.fillWidth: true
						visible: root.failed && text !== ""
						opacity: 0.85
					}
				}

				Rectangle {
					id: bar
					color: root.failed ? Colors.error : Colors.primary
					anchors.bottom: parent.bottom
					anchors.horizontalCenter: parent.horizontalCenter
					height: 4
					radius: 2
					opacity: 0.7

					PropertyAnimation {
						id: anim
						target: bar
						property: "width"
						from: rect.width - 10
						to: 0
						duration: root.failed ? 8000 : 2200
						running: true
						onFinished: popupLoader.active = false
						paused: mouseArea.containsMouse || copyButton.hovered || closeButton.hovered
					}
				}
			}
		}
	}
}
