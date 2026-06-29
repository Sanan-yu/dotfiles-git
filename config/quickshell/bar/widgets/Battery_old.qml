import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.theming

Rectangle {
    id: batteryRectangle
    width: 110
    height: parent.height
    
    color: Colors.surfaceContainerHigh
    radius: Dimensions.radius

    readonly property var battery: UPower.displayDevice
    readonly property real level: battery.isLaptopBattery && battery.ready ? battery.percentage : 0
    readonly property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging
    readonly property string icon: level < 0.2 ? " " : level < 0.4 ? " " : level < 0.6 ? " " : level < 0.8 ? " " : " " 

    Text {
        anchors.centerIn: parent
        
        color: charging 
               ? Colors.secondary 
               : (level < 0.25 ? Colors.error : Colors.onSurface)
               
        font.pixelSize: 18
        text: battery.ready
            ? (batteryRectangle.charging ? " " : "") + Math.round(batteryRectangle.level * 100) + "%" + " " + batteryRectangle.icon
            : "?"
    }
}
