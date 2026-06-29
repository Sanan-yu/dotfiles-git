import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.theming

Rectangle {
	id: systray

	implicitWidth: trayRow.implicitWidth
	implicitHeight: Dimensions.barHeight
	color: "transparent"

	visible: SystemTray.items.values.length > 0

	RowLayout {
		id: trayRow
		anchors.fill: parent
		spacing: 8

		Repeater {
			id: systrayRepeat
			model: SystemTray.items

			delegate: Rectangle {
				required property var modelData

				implicitWidth: 30
				implicitHeight: 30
				radius: 12
				color: Colors.surface

				Image {
					anchors.centerIn: parent
					width: 22
					height: 22
					source: modelData.icon ? modelData.icon : ""
					fillMode: Image.PreserveAspectFit
					smooth: true
				}

				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.AllButtons

					onClicked: (mouse) => {
						if (mouse.button === Qt.RightButton) {
							var pos = parent.mapToGlobal(Qt.point(0, 0))
							menuOpener.anchor.rect.x = pos.x
							menuOpener.anchor.rect.y = pos.y + parent.height + 5
							menuOpener.open()
						} else if (mouse.button === Qt.LeftButton) {
							modelData.activate()
						} else if (mouse.button === Qt.MiddleButton) {
							modelData.secondaryActivate()
						}
					}
				}

				QsMenuAnchor {
					id: menuOpener
					menu: modelData.menu
					anchor.window: panelBar
				}
			}
		}
	}
}
