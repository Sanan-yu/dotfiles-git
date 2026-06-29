pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property var activeNotifications: []
    property int amount: activeNotifications.length
    property bool dnd: false

    function dndToggle() {
        dnd = !dnd;
    }

    function clearAll() {
        for (let i = activeNotifications.length - 1; i >= 0; i--) {
            activeNotifications[i].dismiss();
        }
        activeNotifications = [];
        amount = 0;
    }

    signal notificationReceived(var notification) 
    signal notificationClosed(var notification)

    NotificationServer {
        id: notifServer

        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;
            
            let list = root.activeNotifications;
            list.push(notification);
            root.activeNotifications = list;
            root.amount = list.length;

            notification.onClosed.connect(reason => {
                let currentList = root.activeNotifications;
                const index = currentList.indexOf(notification);
                if (index > -1) {
                    currentList.splice(index, 1);
                    root.activeNotifications = currentList;
                    root.amount = currentList.length;
                }
                root.notificationClosed(notification);
            });

            root.notificationReceived(notification);
        }
    }
}
