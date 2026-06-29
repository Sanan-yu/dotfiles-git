pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property list<var> ddcMonitors: []
    readonly property list<Monitor> monitors: variants.instances
    property bool appleDisplayPresent: false

    function getMonitorForScreen(screen: ShellScreen): var {
        if (!monitors) return null;
        for (var i = 0; i < monitors.length; i++) {
            if (monitors[i].modelData === screen) {
                return monitors[i];
            }
        }
        return null;
    }

    signal monitorBrightnessChanged(var monitor, real newBrightness)

    function getAvailableMethods(): list<string> {
        var methods = [];
        var clearMonitors = root.monitors;
        if (!clearMonitors) return methods;

        var hasDdc = false;
        var hasInternal = false;
        for (var i = 0; i < clearMonitors.length; i++) {
            if (clearMonitors[i].isDdc) hasDdc = true;
            if (!clearMonitors[i].isDdc) hasInternal = true;
        }

        if (hasDdc) methods.push("ddcutil");
        if (hasInternal) methods.push("internal");
        if (appleDisplayPresent) methods.push("apple");
        return methods;
    }

    function increaseBrightness(): void {
        var clearMonitors = root.monitors;
        if (!clearMonitors) return;
        for (var i = 0; i < clearMonitors.length; i++) {
            clearMonitors[i].increaseBrightness();
        }
    }

    function decreaseBrightness(): void {
        var clearMonitors = root.monitors;
        if (!clearMonitors) return;
        for (var i = 0; i < clearMonitors.length; i++) {
            clearMonitors[i].decreaseBrightness();
        }
    }

    reloadableId: "brightness"

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    IpcHandler {
        target: "display"
        function brighter(by: real) {
            var clearMonitors = root.monitors;
            if (!clearMonitors) return;
            for (var i = 0; i < clearMonitors.length; i++) {
                clearMonitors[i].setBrightness(clearMonitors[i].brightness + by);
            }
        }
        function dimmer(by: real) {
            var clearMonitors = root.monitors;
            if (!clearMonitors) return;
            for (var i = 0; i < clearMonitors.length; i++) {
                clearMonitors[i].setBrightness(clearMonitors[i].brightness - by);
            }
        }
    }

    Variants {
        id: variants
        model: Quickshell.screens
        Monitor {}
    }

    Process {
        running: true
        command: ["sh", "-c", "which asdbctl >/dev/null 2>&1 && asdbctl get || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: root.appleDisplayPresent = text.trim().length > 0
        }
    }

    Process {
        id: ddcProc
        property list<var> ddcMonitors: []
        command: ["ddcutil", "detect", "--sleep-multiplier=0.5"]
        stdout: StdioCollector {
            onStreamFinished: {
                var displays = text.trim().split("\n\n");
                var parsedList = [];
                for (var i = 0; i < displays.length; i++) {
                    var d = displays[i];
                    if (!d) continue;
                    var ddcModelMatch = d.match(/This monitor does not support DDC\/CI/);
                    var modelMatch = d.match(/Model:\s*(.*)/);
                    var busMatch = d.match(/I2C bus:[ ]*\/dev\/i2c-([0-9]+)/);
                    var ddcModel = ddcModelMatch ? ddcModelMatch.length > 0 : false;
                    var model = modelMatch ? modelMatch[1] : "Unknown";
                    var bus = busMatch ? busMatch[1] : "Unknown";
                    
                    parsedList.push({
                        "model": model,
                        "busNum": bus,
                        "isDdc": !ddcModel
                    });
                }
                
                var filteredList = [];
                for (var j = 0; j < parsedList.length; j++) {
                    if (parsedList[j].isDdc) {
                        filteredList.push(parsedList[j]);
                    }
                }
                root.ddcMonitors = filteredList;
            }
        }
        stderr: StdioCollector {}
    }

    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData
        readonly property var targetModel: monitor.modelData

        readonly property bool isDdc: {
            if (!root.ddcMonitors || !monitor.targetModel || !monitor.targetModel.model) return false;
            for (var i = 0; i < root.ddcMonitors.length; i++) {
                var item = root.ddcMonitors[i];
                if (item && item.model && item.model === monitor.targetModel.model) {
                    return true;
                }
            }
            return false;
        }

        readonly property string busNum: {
            if (!root.ddcMonitors || !monitor.targetModel || !monitor.targetModel.model) return "";
            for (var i = 0; i < root.ddcMonitors.length; i++) {
                var item = root.ddcMonitors[i];
                if (item && item.model && item.model === monitor.targetModel.model) {
                    return item.busNum ? item.busNum : "";
                }
            }
            return "";
        }
        
        readonly property bool isAppleDisplay: root.appleDisplayPresent && monitor.modelData && monitor.modelData.model && monitor.modelData.model.startsWith("StudioDisplay")
        readonly property string method: isAppleDisplay ? "apple" : (isDdc ? "ddcutil" : "internal")

        property real brightness: 1.0
        property real lastBrightness: 0
        property real queuedBrightness: NaN

        property string backlightDevice: ""
        property string brightnessPath: ""
        property string maxBrightnessPath: ""
        property int maxBrightness: 100
        property bool ignoreNextChange: false

        signal brightnessUpdated(real newBrightness)

        readonly property Process refreshProc: Process {
            stdout: StdioCollector {
                onStreamFinished: {
					var dataText = text.trim();
					if (dataText === "") return;
					if (monitor.isDdc) {
						var parts = dataText.split(" ");
						if (parts.length >= 4) {
							var current = parseInt(parts[3]);
							var max = parseInt(parts[4]);
							if (!isNaN(current) && !isNaN(max) && max > 0) {
								var ddcBright = current / max;
								if (Math.abs(ddcBright - monitor.brightness) > 0.01) {
									monitor.brightness = ddcBright;
									monitor.brightnessUpdated(monitor.brightness);
									root.monitorBrightnessChanged(monitor, monitor.brightness);
								}
							}
						}
					} else {
						var lines = dataText.split("\n");
						if (lines.length >= 2) {
							var current = parseInt(lines[0].trim());
							var max = parseInt(lines[1].trim());
							if (!isNaN(current) && !isNaN(max) && max > 0) {
								var internalBright = current / max;
								if (Math.abs(internalBright - monitor.brightness) > 0.01) {
									monitor.brightness = internalBright;
									monitor.brightnessUpdated(monitor.brightness);
									root.monitorBrightnessChanged(monitor, monitor.brightness);
								}
							}
						}
					}
				}
			}
		}

		function refreshBrightnessFromSystem() {
			if (!monitor.isDdc && !monitor.isAppleDisplay && monitor.brightnessPath !== "" && monitor.maxBrightnessPath !== "") {
				refreshProc.command = ["sh", "-c", "cat " + monitor.brightnessPath + " && cat " + monitor.maxBrightnessPath];
				refreshProc.running = true;
			} else if (monitor.isDdc && monitor.busNum !== "") {
				refreshProc.command = ["ddcutil", "-b", monitor.busNum, "getvcp", "10", "--brief"];
				refreshProc.running = true;
			} else if (monitor.isAppleDisplay) {
				refreshProc.command = ["asdbctl", "get"];
				refreshProc.running = true;
			}
		}

		readonly property FileView brightnessWatcher: FileView {
			id: internalWatcher
			path: (!monitor.isDdc && !monitor.isAppleDisplay && monitor.brightnessPath !== "") ? monitor.brightnessPath : ""
			watchChanges: path !== ""
			onFileChanged: {
				Qt.callLater(function() {
					monitor.refreshBrightnessFromSystem();
				});
			}
		}

		readonly property Process initProc: Process {
			stdout: StdioCollector {
				onStreamFinished: {
					var dataText = text.trim();
					if (dataText === "") return;

					if (monitor.isAppleDisplay) {
						var val = parseInt(dataText);
						if (!isNaN(val)) {
							monitor.brightness = val / 101;
						}
					} else if (monitor.isDdc) {
						var parts = dataText.split(" ");
						if (parts.length >= 4) {
							var current = parseInt(parts[3]);
							var max = parseInt(parts[4]);
							if (!isNaN(current) && !isNaN(max) && max > 0) {
								monitor.brightness = current / max;
							}
						}
					} else {
						var lines = dataText.split("\n");
						if (lines.length >= 3) {
							monitor.backlightDevice = lines[0];
							monitor.brightnessPath = monitor.backlightDevice + "/brightness";
							monitor.maxBrightnessPath = monitor.backlightDevice + "/max_brightness";
							var current = parseInt(lines[1]);
							var max = parseInt(lines[2]);
							if (!isNaN(current) && !isNaN(max) && max > 0) {
								monitor.maxBrightness = max;
								monitor.brightness = current / max;
							}
						}
					}
					monitor.brightnessUpdated(monitor.brightness);
					root.monitorBrightnessChanged(monitor, monitor.brightness);
				}
			}
		}

		readonly property real stepSize: 1 / 100.0

		readonly property Timer debounceTimer: Timer {
			interval: 100
			onTriggered: {
				if (!isNaN(monitor.queuedBrightness)) {
					monitor.setBrightness(monitor.queuedBrightness);
					monitor.queuedBrightness = NaN;
				}
			}
		}

		function setBrightnessDebounced(value: real): void {
			monitor.queuedBrightness = value;
			debounceTimer.start();
		}

		function increaseBrightness(): void {
			var value = !isNaN(monitor.queuedBrightness) ? monitor.queuedBrightness : monitor.brightness;
			setBrightnessDebounced(value + stepSize);
		}

		function decreaseBrightness(): void {
			var value = !isNaN(monitor.queuedBrightness) ? monitor.queuedBrightness : monitor.brightness;
			setBrightnessDebounced(value - stepSize);
		}

		function setBrightness(value: real): void {
			value = Math.max(0, Math.min(1, value));
			var rounded = Math.round(value * 100);

			if (debounceTimer.running) {
				monitor.queuedBrightness = value;
				return;
			}

			monitor.brightness = value;
			monitor.brightnessUpdated(value);
			root.monitorBrightnessChanged(monitor, monitor.brightness);

			if (isAppleDisplay) {
				monitor.ignoreNextChange = true;
				Quickshell.execDetached(["asdbctl", "set", rounded]);
			} else if (isDdc) {
				monitor.ignoreNextChange = true;
				if (busNum !== "") {
					Quickshell.execDetached(["ddcutil", "-b", busNum, "setvcp", "10", rounded]);
				}
			} else {
				monitor.ignoreNextChange = true;
				Quickshell.execDetached(["brightnessctl", "s", rounded + "%"]);
			}

			if (isDdc) {
				debounceTimer.restart();
			}
		}

		function initBrightness(): void {
			if (isAppleDisplay) {
				initProc.command = ["asdbctl", "get"];
			} else if (isDdc) {
				if (busNum !== "") {
					initProc.command = ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"];
				} else {
					return;
				}
			} else {
				initProc.command = ["sh", "-c", "for dev in /sys/class/backlight/*; do if [ -f \"$dev/brightness\" ] && [ -f \"$dev/max_brightness\" ]; then echo \"$dev\"; cat \"$dev/brightness\"; cat \"$dev/max_brightness\"; break; fi; done"];
			}
			initProc.running = true;
		}

		onBusNumChanged: initBrightness()
		Component.onCompleted: initBrightness()
	}
}
