import QtQuick
import Qt5Compat.GraphicalEffects
import qs.theming

Item {
	id: control
	width: 64
	height: 64

	property url iconSource
	property string label
	property bool active: false
	signal clicked()

	Column {
		anchors.centerIn: parent
		spacing: 4

		Rectangle {
			id: indicator
			width: 56
			height: 32
			radius: 16
			anchors.horizontalCenter: parent.horizontalCenter

			color: "transparent"

			Image {
				id: iconImg
				anchors.centerIn: parent
				width: 22
				height: 22
				source: control.iconSource
				smooth: true

				layer {
					enabled: true
					effect: ColorOverlay {
						color: control.active ? Colors.secondaryContainerText : Colors.surfaceVariantText
					}
				}
			}
		}

		Text {
			text: control.label
			font.pixelSize: 12
			color: control.active ? Colors.secondary : Colors.surfaceVariantText
			anchors.horizontalCenter: parent.horizontalCenter
		}
	}

	MouseArea {
		anchors.fill: parent
		onClicked: control.clicked()
	}
}
