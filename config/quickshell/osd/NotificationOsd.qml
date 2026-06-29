import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.sys
import qs.theming
import qs.components.reusable

PanelWindow {
	id: root

	anchors { top: true; right: true }
	margins { top: Dimensions.barHeight + 10; right: 5 }
	color: "transparent"
	implicitWidth: 400
	implicitHeight: Math.min(notifStack.contentHeight, Screen.height - Dimensions.barHeight)

	visible: popupModel.count > 0
	exclusionMode: ExclusionMode.Ignore

	ListModel { id: popupModel }

	ListView {
		id: notifStack
		anchors.fill: parent
		model: popupModel
		spacing: 10
		interactive: false

		// Same animations as bar component
		add: Transition {
			NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
			NumberAnimation { property: "x"; from: 100; to: 0; duration: 250; easing.type: Easing.OutCubic }
		}

		remove: Transition {
			NumberAnimation { property: "opacity"; to: 0; duration: 200 }
			NumberAnimation { property: "scale"; to: 0.8; duration: 200 }
		}

		delegate: Rectangle {
			id: delegateRoot
			width: root.width
			height: 80
			color: Colors.surface
			radius: 8
			border.color: Colors.outlineVariant
			border.width: 1

			Timer {
				id: hideTimer
				interval: {
					if (!model.smartNotif || model.smartNotif.expireTimeout <= 0) {
						return 5000;
					}
					return model.smartNotif.expireTimeout;
				}
				running: true
				repeat: false
				onTriggered: {
					if (!mouseArea.containsMouse && model.smartNotif) {
						for (let i = 0; i < popupModel.count; ++i) {
							if (popupModel.get(i).smartNotif === model.smartNotif) {
								popupModel.remove(i);
								break;
							}
						}
					}
				}
			}

			MouseArea {
				id: mouseArea
				anchors.fill: parent
				hoverEnabled: true
				onClicked: {
					if (model.smartNotif) {
						for (let i = 0; i < popupModel.count; ++i) {
							if (popupModel.get(i).smartNotif === model.smartNotif) {
								popupModel.remove(i);
								break;
							}
						}
					}
				}
			}

			RowLayout {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 12

				IconImage {
					Layout.preferredWidth: 40
					Layout.preferredHeight: 40
					source: (model.smartNotif && model.smartNotif.appIcon !== "") 
					? model.smartNotif.appIcon 
					: Quickshell.iconPath("preferences-desktop-notification-bell")
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 2

					RowLayout {
						Layout.fillWidth: true

						Text {
							text: model.smartNotif ? model.smartNotif.summary : ""
							color: Colors.primary
							font.bold: true
							font.pixelSize: 14
							elide: Text.ElideRight
							Layout.fillWidth: true
						}

						MD3Button {
							text: ""
							initialColor: Colors.primary
							textInitial: Colors.background
							onClicked: if (model.smartNotif) model.smartNotif.dismiss()
						}
					}

					Text {
						text: model.smartNotif ? model.smartNotif.body : ""
						color: Colors.surfaceText
						font.pixelSize: 12
						wrapMode: Text.WordWrap
						maximumLineCount: 2
						elide: Text.ElideRight
						Layout.fillWidth: true
					}
				}
			}
		}
	}

	Connections {
		target: Notifs

		function onNotificationReceived(smartNotifObject) {
			if (!Notifs.dnd) {
				popupModel.insert(0, { "smartNotif": smartNotifObject });
			}
		}

		function onNotificationClosed(smartNotifObject) {
			for (let i = 0; i < popupModel.count; ++i) {
				if (popupModel.get(i).smartNotif === smartNotifObject) {
					popupModel.remove(i);
					break;
				}
			}
		}
	}
}
