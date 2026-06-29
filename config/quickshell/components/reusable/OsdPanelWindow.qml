import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import qs.components
import qs.theming

PanelWindow {
    id: root
    implicitWidth: 250
    implicitHeight: 80
    color: "transparent"
    visible: false
    exclusionMode: ExclusionMode.Ignore

    margins {
        bottom: 100
    }

    anchors {
        bottom: true
    }

    // Prevents engine crash when instantiated inside dynamic models or window contexts
    property var modelData: null

    property bool showing: false
    property QtObject target: null
    property QtObject component: null
    property real sliderValue: 0.5
    
    // Everforest Color Mapping Safety Guards
    property color bgColor: Colors.surface !== undefined ? Colors.surface : "#2d353b"
    property string valueTextIcon: ""
    property string valueTextIconFont: "Jetbrains Mono"
    property color valueTextColor: Colors.primary !== undefined ? Colors.primary : "#a7c080"
    
    property real animationEasing: Easing.OutBack
    property string watchSignal: ""
    property int interval: 3000

    onSliderValueChanged: {
        slider.value = sliderValue
    }

    signal valueChanged(real newValue)

    Timer {
        id: hideContainerTimer
        interval: root.interval
        repeat: false
        onTriggered: root.showing = false
    }

    Timer {
        id: hideViewTimer
        interval: root.interval + 1000
        repeat: false
        onTriggered: root.visible = false
    }

    Component.onCompleted: {
        // Fallback checks just in case system engine theme instances are delayed
        if (Colors.surface) bgColor = Colors.surface;
        if (Colors.primary) valueTextColor = Colors.primary;

        if (root.target && root.watchSignal !== "") {
            var signalRef = root.target[root.watchSignal];
            if (signalRef && typeof signalRef.connect === "function") {
                signalRef.connect(function () {
                    root.showing = true;
                    root.visible = true;
                    hideContainerTimer.restart();
                    hideViewTimer.restart();
                });
            }
        }
    }

    Item {
        id: panelContainer
        anchors.fill: parent

        states: State {
            name: "visible"
            when: root.showing
            PropertyChanges {
                target: panelContent
                y: 10
                opacity: 1
            }
        }

        transitions: Transition {
            NumberAnimation {
                properties: "y, opacity"
                duration: 300
                easing.type: root.animationEasing
            }
        }

        Rectangle {
            id: panelContent
            implicitWidth: 250
            implicitHeight: 50
            color: root.bgColor
            radius: height / 2 - 10
            border.width: 1
            border.color: Colors.outline !== undefined ? Colors.outline : "#859289"
            y: 50
            opacity: 0
            anchors.horizontalCenter: parent.horizontalCenter

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 1.1
                shadowColor: Colors.shadow !== undefined ? Colors.shadow : "#1c2124"
                shadowHorizontalOffset: 4
                shadowVerticalOffset: 4
                shadowOpacity: 0.5
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15

                LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
                LayoutMirroring.childrenInherit: true

				MD3Slider {
					id: slider
					thumbHeight: 30
					thumbWidth: 3
					thumbColor: Colors.primary !== undefined ? Colors.primary : "#a7c080"
					leftTrackColor: Colors.primary !== undefined ? Colors.primary : "#a7c080"
					rightTrackColor: Colors.surfaceVariant !== undefined ? Colors.surfaceVariant : "#343f44"
					trackHeight: 20

					// Bind the slider position to the hardware value coming from the root component
					value: root.sliderValue
					Layout.fillWidth: true

					// CRITICAL: When the user moves the slider, emit the root level signal!
					onMoved: (val) => {
						root.valueChanged(val)
					}
				}

				Text {
					id: iconText
					Layout.leftMargin: 8
					text: root.valueTextIcon
					color: root.valueTextColor
					font.family: root.valueTextIconFont
					font.pixelSize: 16
					opacity: 1.0
				}
			}
		}
	}
}
