// Colors.qml Everforest
pragma Singleton
import QtQuick

QtObject {
    readonly property string mode: "dark"
    readonly property string wallpaper: "/home/sanan/Pictures/system/wall.png"
    readonly property string sourceColor: "#a7c080" // Everforest Green Accent

    readonly property color primary: "#a7c080"
    readonly property color oNPrimary: "#232a2e"
    readonly property color primaryContainer: "#3a464c"
    readonly property color oNPrimaryContainer: "#d3c6aa"
    
    readonly property color primaryFixed: "#a7c080"
    readonly property color primaryFixedDim: "#83c092" // Aqua variation for depth shifting
    readonly property color oNPrimaryFixed: "#232a2e"
    readonly property color oNPrimaryFixedVariant: "#323c41"

    readonly property color secondary: "#83c092"
    readonly property color oNSecondary: "#232a2e"
    readonly property color secondaryContainer: "#343f44"
    readonly property color oNSecondaryContainer: "#d3c6aa"
    
    readonly property color secondaryFixed: "#83c092"
    readonly property color secondaryFixedDim: "#7a9e9f"
    readonly property color oNSecondaryFixed: "#232a2e"
    readonly property color oNSecondaryFixedVariant: "#343f44"

    readonly property color tertiary: "#dbbc7f"
    readonly property color oNTertiary: "#232a2e"
    readonly property color tertiaryContainer: "#3d3832"
    readonly property color oNTertiaryContainer: "#e67e80"
    
    readonly property color tertiaryFixed: "#dbbc7f"
    readonly property color tertiaryFixedDim: "#e67e80" // Terra-cotta Red-Orange variant
    readonly property color oNTertiaryFixed: "#232a2e"
    readonly property color oNTertiaryFixedVariant: "#3d3832"

    readonly property color error: "#e67e80"
    readonly property color oNError: "#232a2e"
    readonly property color errorContainer: "#4c3733"
    readonly property color oNErrorContainer: "#e67e80"

    readonly property color background: "#232a2e" // bg0
    readonly property color oNBackground: "#d3c6aa" // fg
    
    readonly property color surface: "#2d353b" // bg1
    readonly property color oNSurface: "#d3c6aa" // fg
    readonly property color surfaceVariant: "#343f44" // bg2
    readonly property color oNSurfaceVariant: "#9da9a0" // grey
    
    readonly property color surfaceDim: "#232a2e" // bg0
    readonly property color surfaceBright: "#475258" // bg5
    
    readonly property color surfaceContainerLowest: "#1e2326" // Hard background
    readonly property color surfaceContainerLow: "#232a2e"    // bg0
    readonly property color surfaceContainer: "#2d353b"       // bg1
    readonly property color surfaceContainerHigh: "#343f44"   // bg2
    readonly property color surfaceContainerHighest: "#3d484d" // bg3

    readonly property color outline: "#859289" // Status Line / Dark Grey
    readonly property color outlineVariant: "#3d484d" // Subtle divider / bg3

    readonly property color inverseSurface: "#d3c6aa" // Light Foregrounds
    readonly property color inverseOnSurface: "#232a2e"
    readonly property color inversePrimary: "#475258"

    readonly property color shadow: "#1c2124"
    readonly property color scrim: "#1c2124"

    readonly property color term0: "#2d353b" // Black (bg1)
    readonly property color term1: "#e67e80" // Red
    readonly property color term2: "#a7c080" // Green
    readonly property color term3: "#dbbc7f" // Yellow
    readonly property color term4: "#7fbbb3" // Blue
    readonly property color term5: "#d699b6" // Magenta
    readonly property color term6: "#83c092" // Cyan
    readonly property color term7: "#d3c6aa" // White (fg)
    readonly property color term8: "#475258" // Bright Black (bg5)
    readonly property color term9: "#e67e80" // Bright Red
    readonly property color term10: "#a7c080" // Bright Green
    readonly property color term11: "#dbbc7f" // Bright Yellow
    readonly property color term12: "#7fbbb3" // Bright Blue
    readonly property color term13: "#d699b6" // Bright Magenta
    readonly property color term14: "#83c092" // Bright Cyan
    readonly property color term15: "#e6e2dd" // Bright White
}
