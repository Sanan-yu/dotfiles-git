// Media.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects 
import qs.theming
import qs.components.reusable

// The item on top bar
Rectangle {
	id: mediaRectangle
	width: Math.min(activeText.paintedWidth + 50, 300)
	height: Dimensions.barHeight
	color: Colors.surface
	radius: height / 2

	property var rootWindow: null
	property int playerIndex: 0
	property var player: Mpris.players.values && Mpris.players.values.length > 0 ? Mpris.players.values[playerIndex] : null

	// State layer for the bar component
	Rectangle {
		id: stateLayer
		anchors.fill: parent
		radius: parent.radius
		color: Colors.primary
		opacity: mediaMouseArea.containsPress ? 0.12 : (mediaMouseArea.containsMouse ? 0.08 : 0.0)
		Behavior on opacity { NumberAnimation { duration: Anims.duration.expressiveSlowEffects; easing.bezierCurve: Anims.easing.expressiveSlowEffects } }
	}

	onPlayerIndexChanged: {
		if (Mpris.players.values) {
			if (playerIndex >= Mpris.players.values.length) playerIndex = 0;
			if (playerIndex < 0) playerIndex = Mpris.players.values.length - 1;
		}
		musicSlider.value = 0;
	}

	Timer {
		interval: 500
		repeat: true
		running: mediaRectangle.player && mediaRectangle.player.isPlaying
		onTriggered: {
			if (!musicSlider.pressed && mediaRectangle.player && mediaRectangle.player.length > 0) {
				musicSlider.value = mediaRectangle.player.position / mediaRectangle.player.length;
			}
		}
	}

	PopupWindow { 
		id: mediaPopupWin 
		visible: false 
		implicitWidth: 520
		implicitHeight: 280
		color: "transparent" 
		anchor.window: panelBar

		Rectangle {
			anchors.fill: parent
			color: Colors.surfaceContainerLow
			radius: 28
			border.width: 1
			border.color: Colors.outlineVariant

			RowLayout {
				anchors.fill: parent
				anchors.margins: 20
				spacing: 24

				// Album Art (MD3 Rounded Corner Image)
				Rectangle {
					Layout.preferredWidth: 240
					Layout.preferredHeight: 240
					Layout.alignment: Qt.AlignVCenter
					color: Colors.surfaceContainerHighest
					radius: 16
					clip: true

					Image {  
						id: art 
						anchors.fill: parent
						fillMode: Image.PreserveAspectCrop 
						visible: mediaRectangle.player !== null && mediaRectangle.player.trackArtUrl !== undefined && mediaRectangle.player.trackArtUrl !== ""
						source: mediaRectangle.player && mediaRectangle.player.trackArtUrl ? mediaRectangle.player.trackArtUrl : "" 
						layer.enabled: true
						layer.effect: OpacityMask {
							maskSource: Item {
								id: imgMask
								width: art.width
								height: art.height
								Rectangle {
									anchors.fill: parent
									radius: 12
								}
							}
						}
					} 
				}

				ColumnLayout {
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.alignment: Qt.AlignTop | Qt.AlignLeft
					spacing: 8

					Text { 
						color: Colors.primary
						font.family: "Google Sans Flex"
						font.bold: true 
						font.pixelSize: 22
						Layout.fillWidth: true
						elide: Text.ElideRight 
						text: mediaRectangle.player && mediaRectangle.player.trackTitle ? mediaRectangle.player.trackTitle : "No Media Playing" 
					} 

					Text {
						color: Colors.surfaceVariantText
						font.family: "Google Sans Flex"
						font.pixelSize: 14
						Layout.fillWidth: true
						elide: Text.ElideRight
						text: mediaRectangle.player && mediaRectangle.player.trackArtist ? mediaRectangle.player.trackArtist : ""
					}

					// Slider wrapper for padding
					Item {
						Layout.fillWidth: true
						Layout.preferredHeight: 40
						Layout.topMargin: 8

						MD3MediaSlider {
							id: musicSlider
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.verticalCenter: parent.verticalCenter
							thumbColor: Colors.primary
							thumbHeight: 24
							leftTrackColor: Colors.primary
							rightTrackColor: Colors.surfaceVariant
							playing: mediaRectangle.player && mediaRectangle.player.isPlaying && mediaPopupWin.visible
							enabled: mediaRectangle.player !== null && mediaRectangle.player.length > 0
							value: mediaRectangle.player && mediaRectangle.player.length > 0 ? mediaRectangle.player.position / mediaRectangle.player.length : 0
							property bool wasPlaying: false

							onPressedChanged: {
								if (!mediaRectangle.player || !mediaRectangle.player.canSeek || mediaRectangle.player.length <= 0) return;

								if (pressed) {
									wasPlaying = mediaRectangle.player.isPlaying;
									mediaRectangle.player.isPlaying = false;
								} else {
									mediaRectangle.player.position = value * mediaRectangle.player.length;
									mediaRectangle.player.isPlaying = wasPlaying;
								}
							}
						}
					}

					// Media Controls (Standard MD3 Layout)
					RowLayout {
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignHCenter
						Layout.topMargin: 8
						spacing: 8

						// Previous / Skip Backward (Standard Icon Button)
						MD3Button {
							id: prevButton
							Layout.preferredWidth: 56
							Layout.preferredHeight: 56
							fontSize: 28
							enabled: mediaRectangle.player !== null
							fontFamily: "Material Symbols"
							initialColor: "transparent"
							pressedColor: Colors.secondaryContainer
							textInitial: Colors.surfaceText
							textPressed: Colors.secondaryContainerText
							radius: 28
							text: "󰒮"
							onClicked: if (mediaRectangle.player) mediaRectangle.player.previous()
						}

						// Play/Pause (MD3 Filled Tonal Button)
						MD3ToggleButton {
							id: playButton
							Layout.preferredWidth: 80
							Layout.preferredHeight: 56
							fontSize: 32
							enabled: mediaRectangle.player !== null
							onClicked: if (mediaRectangle.player) mediaRectangle.player.isPlaying = !mediaRectangle.player.isPlaying
							pressed: mediaRectangle.player ? mediaRectangle.player.isPlaying : false
							initialColor: Colors.primaryContainer
							pressedColor: Colors.primary
							textInitial: Colors.primaryContainerText
							textPressed: Colors.primaryText
							radius: mediaRectangle.player ? (mediaRectangle.player.isPlaying ? 12 : 28) : 28
							text: mediaRectangle.player ? (mediaRectangle.player.isPlaying ? "󰏤" : "󰐊") : "󰐊"
						}

						// Next / Skip Forward (Standard Icon Button)
						MD3Button {
							id: nextButton
							Layout.preferredWidth: 56
							Layout.preferredHeight: 56
							fontSize: 28
							enabled: mediaRectangle.player !== null
							fontFamily: "Material Symbols"
							initialColor: "transparent"
							pressedColor: Colors.secondaryContainer
							textInitial: Colors.surfaceText
							textPressed: Colors.secondaryContainerText
							radius: 28
							text: "󰒭"
							onClicked: if (mediaRectangle.player) mediaRectangle.player.next()
						}
					}

					// Player Switcher Row
					RowLayout {
						Layout.fillWidth: true
						Layout.topMargin: 12
						spacing: 8

						MD3Button {
							id: changePlayerBackwardButton
							Layout.fillWidth: true
							Layout.preferredHeight: 40
							enabled: Mpris.players.values && Mpris.players.values.length > 1
							fontSize: 20
							fontFamily: "Material Symbols"
							initialColor: "transparent"
							pressedColor: Colors.surfaceContainerHighest
							textInitial: Colors.surfaceText
							textPressed: Colors.surfaceText
							radius: 20
							text: "󰅁"
							onClicked: {
								if (Mpris.players.values && Mpris.players.values.length > 0) {
									mediaRectangle.playerIndex = mediaRectangle.playerIndex > 0 ? mediaRectangle.playerIndex - 1 : Mpris.players.values.length - 1;
								}
							}
						}

						MD3Button {
							id: changePlayerForwardButton
							Layout.fillWidth: true
							Layout.preferredHeight: 40
							enabled: Mpris.players.values && Mpris.players.values.length > 1
							fontSize: 20
							fontFamily: "Material Symbols"
							initialColor: "transparent"
							pressedColor: Colors.surfaceContainerHighest
							textInitial: Colors.surfaceText
							textPressed: Colors.surfaceText
							radius: 20
							text: "󰅂"
							onClicked: {
								if (Mpris.players.values && Mpris.players.values.length > 0) {
									mediaRectangle.playerIndex = (mediaRectangle.playerIndex + 1) % Mpris.players.values.length;
								}
							}
						}
					}
				}
			} 
		}

		HyprlandFocusGrab {
			id: grab
			windows: [ mediaPopupWin ]
			onCleared: mediaPopupWin.visible = false
		}
	}

	MouseArea {
		id: mediaMouseArea
		anchors.fill: parent 
		acceptedButtons: Qt.AllButtons
		hoverEnabled: true

		onClicked: (mouse) => {
			if (mouse.button === Qt.RightButton) {
				var pos = mediaRectangle.mapToGlobal(Qt.point(0, 0));
				mediaPopupWin.anchor.rect.x = pos.x + mediaRectangle.width / 2 - mediaPopupWin.implicitWidth / 2;
				mediaPopupWin.anchor.rect.y = pos.y + mediaRectangle.height + 6;
				mediaPopupWin.visible = !mediaPopupWin.visible;
				grab.active = mediaPopupWin.visible;
			} else if (mouse.button === Qt.LeftButton) {
				if (mediaRectangle.player) {
					if (mediaRectangle.player.isPlaying) {
						mediaRectangle.player.pause();
					} else {
						mediaRectangle.player.play();
					}
				}
			}
		}

		Text {
			id: activeText
			anchors.centerIn: parent
			width: 300 
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			wrapMode: Text.NoWrap
			elide: Text.ElideRight
			color: mediaRectangle.player && mediaRectangle.player.isPlaying ? Colors.primary : Colors.surfaceText
			font.pixelSize: 15
			font.family: "Google Sans Code NF"
			text: mediaRectangle.player && mediaRectangle.player.trackTitle && mediaRectangle.player.trackArtist 
			? mediaRectangle.player.trackArtist + " - " + mediaRectangle.player.trackTitle + "  "
			: "Media  " 

			Behavior on color { ColorAnimation { duration: Anims.mediumDur } }
		}
	}
}
