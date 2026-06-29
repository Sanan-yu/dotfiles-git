pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property QtObject duration: QtObject {
        readonly property int expressiveFastSpatial: 350
        readonly property int expressiveDefaultSpatial: 500
        readonly property int expressiveSlowSpatial: 650

        readonly property int expressiveFastEffects: 150
        readonly property int expressiveDefaultEffects: 200
        readonly property int expressiveSlowEffects: 300

        readonly property int standardFastSpatial: 350
        readonly property int standardDefaultSpatial: 500
        readonly property int standardSlowSpatial: 750

        readonly property int standardFastEffects: 150
        readonly property int standardDefaultEffects: 200
        readonly property int standardSlowEffects: 300
    }

    readonly property QtObject easing: QtObject {
        readonly property var expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1.0, 1.0]
        readonly property var expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1.0, 1.0]
        readonly property var expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1.0, 1.0]

        readonly property var expressiveFastEffects: [0.31, 0.94, 0.34, 1.00, 1.0, 1.0]
        readonly property var expressiveDefaultEffects: [0.34, 0.80, 0.34, 1.00, 1.0, 1.0]
        readonly property var expressiveSlowEffects: [0.34, 0.88, 0.34, 1.00, 1.0, 1.0]

        readonly property var standardFastSpatial: [0.27, 1.06, 0.18, 1.00, 1.0, 1.0]
        readonly property var standardDefaultSpatial: [0.27, 1.06, 0.18, 1.00, 1.0, 1.0]
        readonly property var standardSlowSpatial: [0.27, 1.06, 0.18, 1.00, 1.0, 1.0]

        readonly property var standardFastEffects: [0.31, 0.94, 0.34, 1.00, 1.0, 1.0]
        readonly property var standardDefaultEffects: [0.34, 0.80, 0.34, 1.00, 1.0, 1.0]
        readonly property var standardSlowEffects: [0.34, 0.88, 0.34, 1.00, 1.0, 1.0]
    }
}
