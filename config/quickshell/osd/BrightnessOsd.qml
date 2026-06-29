import QtQuick
import Quickshell.Wayland
import Quickshell
import qs.sys
import qs.theming
import qs.components.reusable

Scope {
    id: scopeRoot
    
    Timer {
        id: hideTimer
        interval: 2200
        repeat: false
        onTriggered: {
            osdContainer.visible = false
        }
    }

    Connections {
        target: typeof Brightness !== "undefined" ? Brightness : null
        ignoreUnknownSignals: true
        
        function onMonitorBrightnessChanged(monitor, newBrightness) {
            osdContainer.visible = true
            hideTimer.restart()
        }
    }

    Variants {
        id: osdContainer
        property bool visible: false
        model: Quickshell.screens
        
        delegate: OsdPanelWindow {
            id: popup
            
			screen: modelData
            
            visible: osdContainer.visible
            showing: osdContainer.visible
            
            WlrLayershell.layer: WlrLayer.Overlay
            
            bgColor: Colors.surface !== undefined ? Colors.surface : "#2d353b"
            valueTextColor: Colors.primary !== undefined ? Colors.primary : "#a7c080"

			readonly property var monitor: Brightness.monitors[0] // temporary, gonna find out how to set multi-monitor up properly
			//          readonly property var monitor: {
			//              if (typeof Brightness !== "undefined" && Brightness.monitors && Variants.index < Brightness.monitors.length) {
			//                  return Brightness.monitors[Variants.index];
			//              }
			// 	return null;
			// }

			target: popup.monitor
			watchSignal: "brightnessChanged"

			sliderValue: popup.monitor ? popup.monitor.brightness : 0

			valueTextIcon: {
				if (!popup.monitor) return "󰃞"
				var b = popup.monitor.brightness
				if (b < 0.34) return "󰃞"
				if (b < 0.67) return "󰃟"
				return "󰃠"
			}

			onValueChanged: (v) => {
				if (popup.monitor && Math.abs(popup.monitor.brightness - v) > 0.01) {
					console.log(popup.monitor.brightness);
					popup.monitor.setBrightness(v);
					hideTimer.restart();
				}
			}
		}
	}
}
