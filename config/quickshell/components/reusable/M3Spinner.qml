import QtQuick
import Quickshell
import M3Shapes
import qs.theming

MaterialShape {
	id: root

	width: 64
	height: 64
	color: Colors.primary

	property real stiffness: 150
	property real dampingRatio: 0.4
	property real visibilityThreshold: 0.01
	rotation: 100

	readonly property real zFactor: dampingRatio 

	readonly property real springDuration: {
		const wn = Math.sqrt(stiffness);
		const r = -dampingRatio * wn;
		const c = 1 / Math.sqrt(1 - dampingRatio * dampingRatio);
		return Math.log(visibilityThreshold / c) / r;
	}

	readonly property real springMaxVelocity: {
		const wn = Math.sqrt(stiffness);
		const factor = Math.exp(-zFactor * Math.acos(zFactor) / Math.sqrt(1 - zFactor * zFactor));
		return wn * factor;
	}

	property bool springSettled: true

	function spring(t) {
		const wn = Math.sqrt(stiffness);
		const za = dampingRatio * wn;
		const wd = wn * Math.sqrt(1 - dampingRatio * dampingRatio);
		const r = za / wd;
		const pos = 1 - Math.exp(-za * t) * (Math.cos(wd * t) + r * Math.sin(wd * t));
		const vel = Math.exp(-za * t) * (wn * wn / wd) * Math.sin(wd * t);
		return [pos, vel];
	}

	property bool animated: true
	property real morphAnimRotation: 90
	property real morphScale: 0.125

	property real cRotation: 0
	property real lRotation: 0
	property real thisLRotation: 0

	property var shapes: [
		MaterialShape.Cookie9Sided, 
		MaterialShape.Pentagon, 
		MaterialShape.Pill, 
		MaterialShape.Sunny,
		MaterialShape.Cookie4Sided,
		MaterialShape.Oval,
		MaterialShape.SoftBurst
	]
	property int shapeIndex: 0

	fromShape: MaterialShape.Circle
	morphProgress: 0
	animationEasing: Easing.InOutQuad

	ElapsedTimer {
		id: timer
	}

	FrameAnimation {
		running: root.animated && !root.springSettled
		onTriggered: {
			const t = timer.elapsed();

			if (t >= root.springDuration) {
				root.springSettled = true;
				root.morphProgress = 1.0;
				root.scale = 1.0;
				root.thisLRotation = root.morphAnimRotation;
			} else {
				const [pos, vel] = root.spring(t);
				root.morphProgress = pos;
				root.thisLRotation = pos * root.morphAnimRotation;
				root.scale = 1 + vel * root.morphScale / root.springMaxVelocity;
			}

			root.rotation = root.cRotation + root.lRotation + root.thisLRotation;
		}
	}

	Timer {
		interval: 650
		repeat: true
		triggeredOnStart: true
		running: root.animated
		onTriggered: {
			root.beginBatchUpdate();

			root.fromShape = root.toShape;
			root.shapeIndex = (root.shapeIndex + 1) % root.shapes.length;
			root.toShape = root.shapes[root.shapeIndex];
			root.morphProgress = 0;

			root.rotation = root.rotation
			root.lRotation = (root.lRotation + root.thisLRotation) % 360;
			root.thisLRotation = 0;
			root.rotation = Qt.binding(() => root.cRotation + root.lRotation + root.thisLRotation);

			root.springSettled = false;
			timer.restart();

			root.endBatchUpdate();
		}
	}
}
