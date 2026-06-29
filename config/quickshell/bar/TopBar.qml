import Quickshell
import QtQuick
import QtQuick.Layouts
import "./widgets"
import qs.components
import qs.theming

PanelWindow {
	id: panelBar

	anchors {
		top: Dimensions.barPosition === Edges.Top
		bottom: Dimensions.barPosition === Edges.Bottom
		left: true
		right: true
	}

	margins {
		left: 5
		right: 5
		top: 5
		bottom: 5
	}
	required property var modelData
	screen: modelData

	implicitHeight: Dimensions.barHeight
	color: "transparent"

	RowLayout {
		anchors.fill: parent
		anchors.leftMargin: 5
		anchors.rightMargin: 5
		spacing: 5

		RowLayout {
			Layout.alignment: Qt.AlignLeft
			spacing: 5

			Workspaces { id: workspaceRect }
			Window { id: windowRect }
			Caffeine { id: caffRect }
			Clock { id: clockRect }
		}

		RowLayout {
			Layout.alignment: Qt.AlignRight
			spacing: 5

			Systray { id: systrayRect }
			BluetoothPart { id: bluetoothRect }
			Network { id: networkRect }
			Battery { id: battteryRect }
			NotificationsPart { id: notifsRect }
		}
	}
	Item {
		anchors.fill: parent

		Media { 
			id: mediaRect
			anchors.centerIn: parent
		}
	}
}
