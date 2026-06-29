import QtQuick
import Quickshell.Hyprland
import qs.theming

Rectangle{
    id: workspacesRect
    property real circleHeight: 10
	property real focusedWidth: 60
    // color: "transparent"
    width: (workspacesRow.spacing + circleHeight) * (repeaterComponent.model - 1) + focusedWidth + 20
    height: Dimensions.barHeight
	color: Colors.surface
	radius: height / 2
    Row{
        id: workspacesRow
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        Repeater{
            id: repeaterComponent
            model: 10
            delegate: Rectangle{
                readonly property real realid: modelData + 1
                readonly property bool exists: Hyprland.workspaces.values.some(ws => ws.id === realid)
                readonly property bool isFocused: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === realid : false
                width: isFocused ? workspacesRect.focusedWidth : workspacesRect.circleHeight
                height: workspacesRect.circleHeight
                radius: height / 2
                color: isFocused ? Colors.primary : exists ? Colors.primary : Colors.inverseSurface
                MouseArea{
                    anchors.fill: parent
                    onClicked: if(Hyprland.focusedWorkspace.id !== realid) Hyprland.dispatch("hl.dsp.focus({workspace = " + realid+ "})")
                }
                Behavior on width{
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
