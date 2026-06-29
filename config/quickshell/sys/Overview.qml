pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Widgets
import qs.theming
import qs.components

Scope {
  id: root
  property ShellScreen focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) 
  property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
  property real spacing: 8
  property real columns: 5
  property real rows: 2
  property real contentWidth: (focusedMonitor?.width / focusedMonitor?.scale) / 1.5
  property real tileWidth: (contentWidth - spacing * (columns + 1)) / columns
  property real tileHeight: tileWidth * 9 / 16

  
  PanelWindow {
    id: overviewWindow
    screen: root.focusedScreen
    color: "transparent"

    implicitWidth: contentWidth
    implicitHeight: tileHeight * rows + spacing * (rows + 1)

    // mask: Region { item: Rectangle {anchors.fill: parent} }
    
    Rectangle { 
      id: overviewWindowRect
      color: Colors.surface
      anchors.fill: parent
      radius: 12
      GridLayout {
        id: overviewLayout
        anchors.fill: parent
        anchors.margins: spacing

        columns: root.columns
        rows: root.rows
        rowSpacing: 8
        columnSpacing: 8

        Repeater {
          model: root.rows * root.columns
          WorkspaceView {
            parentWindow: overviewWindowRect
            implicitWidth: root.tileWidth 
            implicitHeight: root.tileHeight

			DropArea {
				anchors.fill: parent
				onDropped: function(drag) {
					var address = drag.source.address
					var cmd = 'hl.dsp.window.move({ workspace = ' + (index + 1) + ', window = "address:' + address + '", follow = false })'
					Hyprland.dispatch(cmd)
					Hyprland.refreshWorkspaces()
					Hyprland.refreshMonitors()
					Hyprland.refreshToplevels()
				}
			}
		}
	}
}
	}
}
}
