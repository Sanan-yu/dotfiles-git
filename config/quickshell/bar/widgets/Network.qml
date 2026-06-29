// Network.qml

import QtQuick
import Quickshell
import Quickshell.Networking
import qs.theming

// Not using MD3ToggleButton or smt like that, don't want to accidentaly turn off my internet
// Also planning to add a popup
Rectangle {
    id: networkRect
    width: 80
    height: Dimensions.barHeight
    color: Colors.surface
    radius: 8

    property NetworkDevice device: {
        if (Networking.devices && Networking.devices.values && Networking.devices.values.length > 0) {
            return Networking.devices.values[0];
        }
        return null;
    }

    property ObjectModel networks: {
        if (!device || device.type !== DeviceType.Wifi || device.mode !== WifiDeviceMode.Station) {
            return null;
        }
        return device.networks;
    }

    property WifiNetwork currentNetwork: {
        if (!networks || !networks.values || networks.values.length === 0) {
            return null;
        }
        var primaryNet = networks.values[0];
        return (primaryNet && primaryNet.connected) ? primaryNet : null;
    }

    property real level: currentNetwork ? currentNetwork.signalStrength : 0
    
    readonly property string icon: {
        if (!isConnected) return "󰤮 ";
        if (level < 0.2) return "󰤯 ";
        if (level < 0.4) return "󰤟 ";
        if (level < 0.6) return "󰤢 ";
        if (level < 0.8) return "󰤥 ";
        return "󰤨 ";
    }
    
    readonly property bool isConnected: device ? device.connected : false

    Text {
        id: networkText
        font.family: "Google Sans Code NF"
        font.pixelSize: 13
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        width: parent.width - 12
        
        text: (networkRect.isConnected && networkRect.currentNetwork && networkRect.currentNetwork.name)
            ? networkRect.icon + " " + networkRect.currentNetwork.name
            : networkRect.icon + " Disconnected"
            
        color: networkRect.isConnected ? Colors.surfaceText : Colors.surfaceVariant
    }
}
