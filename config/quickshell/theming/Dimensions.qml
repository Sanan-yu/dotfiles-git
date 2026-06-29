pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: sizes
	readonly property real barHeight: 30
	readonly property var barPosition: Edges.Top // Improper usage but it won't cause problems
	readonly property real radius: 12
}
