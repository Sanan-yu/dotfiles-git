pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import qs.theming

ClippingRectangle {
  visible: true 
  id: root
  required property int index
  required property Item parentWindow
  property HyprlandWorkspace wsp: Hyprland.workspaces.values.find(s => s.id == (index + 1)) || null 
  property real scaleFactor: (wsp?.monitor) ? ((wsp.monitor.width / wsp.monitor.scale) / implicitWidth) : -1
  color: "transparent"
  border {
    width: 2
    color: Colors.oNSurface
  }
  radius: 12

  Connections {
    target: (root.wsp) ? root.wsp?.toplevels : null
    function onObjectInsertedPost() { Hyprland.refreshToplevels() }
    function onObjectRemovedPre() { Hyprland.refreshToplevels() }
    function onObjectRemovedPost() { Hyprland.refreshToplevels() }
    function onObjectInsertedPre() {Hyprland.refreshToplevels() }
  }

  Text {
    font.family: "Jetbrains Mono"
    color: Colors.oNSurface
    text: root.index + 1
    anchors.centerIn: parent
  }

  Repeater {
    model: (root.wsp) ? root.wsp.toplevels : []
    ScreencopyView {
      id: scView
      required property HyprlandToplevel modelData
      property string address: modelData.lastIpcObject.address ? modelData.lastIpcObject.address : null
      captureSource: modelData.wayland
      live: true 
      x: (modelData.lastIpcObject.at && root.wsp?.monitor) ? ((modelData.lastIpcObject.at[0] - root.wsp.monitor.x) / root.scaleFactor) : 0
      y: (modelData.lastIpcObject.at && root.wsp?.monitor) ? ((modelData.lastIpcObject.at[1] - root.wsp.monitor.y) / root.scaleFactor) : 0
      width: (modelData.lastIpcObject.size && root.wsp) ? ((modelData.lastIpcObject.size[0]) / root.scaleFactor) : 0
      height: (modelData.lastIpcObject.size && root.wsp) ? ((modelData.lastIpcObject.size[1]) / root.scaleFactor) : 0

      Component.onCompleted: Hyprland.refreshToplevels()

      DragHandler {
        id: dragHandler
        target: scView
        onActiveChanged: {
          if (!active) { 
            target.Drag.drop()
            
          }
        }
      }

      Drag.active: dragHandler.active
      Drag.source: scView
      Drag.supportedActions: Qt.MoveAction
      Drag.hotSpot.x: width / 2
      Drag.hotSpot.y: height / 2

      states: [
        State {
          when: dragHandler.active
          ParentChange {
            target: scView
            parent: root.parentWindow 
          }
        }
      ]
    }
  }
}
