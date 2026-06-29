import QtQuick
import Quickshell.Wayland
import Quickshell
import qs.sys
import qs.theming
import qs.components.reusable

Scope {
    Variants {
        model: Quickshell.screens
        
        delegate: OsdPanelWindow {
            id: root
            visible: true
            WlrLayershell.layer: WlrLayer.Overlay
            bgColor: Colors.surfaceContainerHigh

            target: typeof Audio !== "undefined" ? Audio : null
            sliderValue: typeof Audio !== "undefined" ? Audio.volume : 0
            watchSignal: "volumeChanged"
            
            valueTextIcon: {
                if (typeof Audio === "undefined") return ""
                const vol = Audio.volume
                if (Audio.muted) {
                    return ""
                } else if (vol < 0.30) {
                    return ""
                } else if (vol < 0.70) {
                    return ""
                } else {
                    return ""
                }
            }
            
            onValueChanged: v => { 
                if (typeof Audio !== "undefined") Audio.setVolume(v) 
            }
            
            Connections {
                target: typeof Audio !== "undefined" ? Audio : null
                ignoreUnknownSignals: true
                function onVolumeChanged() {
                    root.sliderValue = Audio.volume
                }
            }
        }
    }
}
