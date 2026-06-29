// Colors.qml.template
pragma Singleton
import QtQuick

QtObject {
	readonly property string mode: "Dark" 
	readonly property string wallpaper: "/home/sanan/Pictures/system/dark_hole.png"
	readonly property color sourceColor: "#d66419"

	readonly property color fallbackError: "#8B0000"

	readonly property color primary: "#ffb690"
	readonly property color primaryText: "#542202"
	readonly property color primaryContainer: "#703715"
	readonly property color primaryContainerText: "#ffdbcb"

	readonly property color primaryFixed: "#ffdbcb"
	readonly property color primaryFixedDim: "#ffb690"
	readonly property color primaryFixedText: "#341100"
	readonly property color primaryFixedVariantText: "#703715"

	readonly property color secondary: "#e6beab"
	readonly property color secondaryText: "#432b1e"
	readonly property color secondaryContainer: "#5c4032"
	readonly property color secondaryContainerText: "#ffdbcb"

	readonly property color secondaryFixed: "#ffdbcb"
	readonly property color secondaryFixedDim: "#e6beab"
	readonly property color secondaryFixedText: "#2b160b"
	readonly property color secondaryFixedVariantText: "#5c4032"

	readonly property color tertiary: "#cfc890"
	readonly property color tertiaryText: "#353107"
	readonly property color tertiaryContainer: "#4c481c"
	readonly property color tertiaryContainerText: "#ebe4aa"

	readonly property color tertiaryFixed: "#ebe4aa"
	readonly property color tertiaryFixedDim: "#cfc890"
	readonly property color tertiaryFixedText: "#1f1c00"
	readonly property color tertiaryFixedVariantText: "#4c481c"

	readonly property color error: "#ffb4ab"
	readonly property color errorText: "#690005"
	readonly property color errorContainer: "#93000a"
	readonly property color errorContainerText: "#ffdad6"

	readonly property color background: "#1a120e"
	readonly property color backgroundText: "#f0dfd8"

	readonly property color surface: "#1a120e"
	readonly property color surfaceText: "#f0dfd8"
	readonly property color surfaceVariant: "#52443d"
	readonly property color surfaceVariantText: "#d7c2b9"

	readonly property color surfaceDim: "#1a120e"
	readonly property color surfaceBright: "#413732"

	readonly property color surfaceContainerLowest: "#140c09"
	readonly property color surfaceContainerLow: "#221a15"
	readonly property color surfaceContainer: "#271e19"
	readonly property color surfaceContainerHigh: "#322823"
	readonly property color surfaceContainerHighest: "#3d332e"

	readonly property color outline: "#a08d84"
	readonly property color outlineVariant: "#52443d"

	readonly property color inverseSurface: "#f0dfd8"
	readonly property color inverseOnSurface: "#382e2a"
	readonly property color inversePrimary: "#8d4e2a"

	readonly property color shadow: "#000000"
	readonly property color scrim: "#000000"
}
