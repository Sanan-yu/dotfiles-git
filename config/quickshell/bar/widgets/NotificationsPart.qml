// NotificationsPart.qml

import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import qs.theming
import qs.components.reusable
import qs.sys

// Item on the bar, not responsible for osd(on screen display) notifs, find them in <root>/osd/NotifsOsd.qml
MD3ToggleButton {
	id: notifsRect
	height: Dimensions.barHeight
	width: 40

	// MD3 Guidelines: Standard Surface variant
	initialColor: Colors.surface
	pressedColor: Colors.errorContainer
	textInitial: Colors.surfaceVariantText
	textPressed: Colors.errorContainerText

	pressed: Notifs.dnd
	text: Notifs.dnd ? "󰂛" : "󰂚"
	fontSize: 18
	fontFamily: "Material Symbols"

	// MD3 State Layer for the bar icon
	Rectangle {
		id: stateLayer
		anchors.fill: parent
		radius: parent.radius
		color: Colors.surfaceText
		opacity: notifsRect.containsPress ? 0.12 : (notifsRect.containsMouse ? 0.08 : 0.0)
		Behavior on opacity { NumberAnimation { duration: Anims.duration.expressiveFastEffects; easing.bezierCurve: Anims.easing.expressiveFastEffects } }
	}

	PopupWindow {
		id: notifsPopupWin
		visible: false
		implicitWidth: 380
		implicitHeight: 550
		color: "transparent"
		anchor.window: panelBar

		ListModel { id: notifsModel }

		Rectangle {
			anchors.fill: parent
			color: Colors.surfaceContainerLow
			radius: 28
			border.width: 1
			border.color: Colors.outlineVariant

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 16
				spacing: 16

				// Popup Header
				RowLayout {
					Layout.fillWidth: true
					spacing: 12

					Text {
						text: "Notifications"
						color: Colors.surfaceText
						font.family: "Google Sans Text"
						font.pixelSize: 22
						font.weight: Font.Medium
						Layout.alignment: Qt.AlignVCenter
					}

					Item { Layout.fillWidth: true }

					// MD3 Text Button
					MD3Button {
						text: "Clear all"
						initialColor: "transparent"
						pressedColor: Colors.surfaceContainerHighest
						textInitial: Colors.primary
						textPressed: Colors.primary
						fontSize: 14
						fontFamily: "Google Sans Text"
						width: 100
						radius: 20
						onClicked: Notifs.clearAll()
					}
				}

				// Notifications List
				ListView {
					id: notifList
					Layout.fillWidth: true
					Layout.fillHeight: true
					model: notifsModel
					spacing: 10
					clip: true

					// MD3 Transition: Entrance from top with spring physics
					add: Transition {
						NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Anims.mediumDur }
						SpringAnimation { property: "y"; from: -40; to: 0; spring: 3; damping: 0.4; epsilon: 0.05 }
					}

					// MD3 Transition: Dismissal with scale down and fade
					remove: Transition {
						NumberAnimation { property: "opacity"; to: 0; duration: Anims.shortDur }
						SpringAnimation { property: "scale"; to: 0.8; spring: 3; damping: 0.4; epsilon: 0.05 }
					}

					displaced: Transition {
						NumberAnimation { property: "y"; duration: Anims.mediumDur; easing.bezierCurve: Anims.standardEasing }
						NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Anims.mediumDur }
					}

					delegate: Rectangle {
						id: notifDelegate
						width: notifList.width
						height: notifColumn.implicitHeight + 32 // 16px top/bottom padding
						color: Colors.surfaceContainerHigh
						radius: 16
						border.color: Colors.outlineVariant
						border.width: 1

						ColumnLayout {
							id: notifColumn
							anchors.fill: parent
							anchors.margins: 16
							spacing: 8

							RowLayout {
								Layout.fillWidth: true
								spacing: 8

								Text { 
									text: model.smartNotif ? model.smartNotif.summary : ""
									color: Colors.surfaceText
									font.family: "Google Sans Text"
									font.bold: true 
									font.pixelSize: 15
									Layout.fillWidth: true
									elide: Text.ElideRight
								}

								MD3Button {
									text: "󰅖"
									initialColor: "transparent"
									pressedColor: Colors.surfaceContainerHighest
									textInitial: Colors.surfaceVariantText
									textPressed: Colors.surfaceText
									fontSize: 20
									fontFamily: "Material Symbols"
									onClicked: if (model.smartNotif) model.smartNotif.dismiss()
								}
							}

							Text { 
								text: model.smartNotif ? model.smartNotif.body : ""
								color: Colors.surfaceVariantText
								font.family: "Google Sans Text"
								font.pixelSize: 14
								Layout.fillWidth: true
								wrapMode: Text.Wrap
							}
						}

						MouseArea {
							anchors.fill: parent
							drag.target: notifDelegate
							drag.axis: Drag.XAxis
							drag.minimumX: -notifDelegate.width
							drag.maximumX: 0

							onReleased: {
								if (notifDelegate.x < -notifDelegate.width / 2) {
									if (model.smartNotif) model.smartNotif.dismiss();
								} else {
									returnXAnim.start();
								}
							}

							NumberAnimation {
								id: returnXAnim
								target: notifDelegate
								property: "x"
								to: 0
								duration: Anims.mediumDur
								easing.bezierCurve: Anims.standardEasing
							}
						}
					}
				}

				Text {
					Layout.fillWidth: true
					Layout.fillHeight: true
					visible: notifsModel.count === 0
					text: "No notifications"
					color: Colors.surfaceVariantText
					font.family: "Google Sans Text"
					font.pixelSize: 14
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}

			Connections {
				target: Notifs

				function onNotificationReceived(smartNotifObject) {
					notifsModel.insert(0, {
						"smartNotif": smartNotifObject
					});
				}

				function onNotificationClosed(smartNotifObject) {
					for (let i = 0; i < notifsModel.count; ++i) {
						if (notifsModel.get(i).smartNotif === smartNotifObject) {
							notifsModel.remove(i);
							break;
						}
					}
				}
			}
		}

		HyprlandFocusGrab {
			id: grab
			windows: [ notifsPopupWin ]
			onCleared: notifsPopupWin.visible = false
		}
	}

	onClicked: (mouse) => {
		if (mouse.button === Qt.LeftButton) {
			Notifs.dnd = !Notifs.dnd;
		} else if (mouse.button === Qt.RightButton) {
			var pos = notifsRect.mapToGlobal(Qt.point(0, 0));
			notifsPopupWin.anchor.rect.x = pos.x + notifsRect.width / 2 - notifsPopupWin.implicitWidth / 2;
			notifsPopupWin.anchor.rect.y = pos.y + notifsRect.height + 6;
			notifsPopupWin.visible = !notifsPopupWin.visible;
			grab.active = notifsPopupWin.visible;
		}
	}
}
