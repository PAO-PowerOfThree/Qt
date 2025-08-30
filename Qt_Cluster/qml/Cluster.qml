import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Effects 2.15
import PaoCluster

ApplicationWindow {
    id: window
    width: 1024
    height: 600
    visible: true
    color: "black" // fallback

    // Property to hold the current speed
    property string currentSpeed: "0"
    property bool serverAvailable: false

    // Background image fills everything
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/assets/backgr.png"
        fillMode: Image.Stretch
    }

    // Car image overlay
    Image {
        id: carImage
        anchors.centerIn: parent
        source: "qrc:/assets/carcora.png"
        fillMode: Image.PreserveAspectFit
        width: parent.width * 0.6
        height: parent.height * 0.6
    }

    // Connect to VSomeIPClient signals
    Connections {
        target: vsomeipClient
        function onMessageReceived(message) {
            // Parse the message to extract the numeric speed (e.g., "50" from "Simulated speed = 50")
            var speed = message.split("=")[1]?.trim() || "0"
            currentSpeed = speed.match(/^\d+$/) ? speed : "0" // Ensure only numeric values are used
        }
        function onServerAvailabilityChanged(isAvailable) {
            serverAvailable = isAvailable
            // Do not change currentSpeed; keep it as the last received numeric value or "0"
        }
    }

    // Close button at top-left corner
    Button {
        id: closeButton
        width: 30
        height: 30
        text: "X"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        background: Rectangle {
            color: "#333333"
            radius: 5
            border.color: "#888888"
            border.width: 1
        }
        contentItem: Text {
            text: closeButton.text
            color: "#888888"
            font.pixelSize: 16
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: {
            Qt.quit()
        }
    }

    // Server availability indicator at top-right corner
    Rectangle {
        width: 20
        height: 20
        radius: 10 // Circular button
        color: serverAvailable ? "green" : "red"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 10
    }

    Item {
        id: topBar
        width: parent.width
        height: 51
        anchors.top: parent.top
        anchors.topMargin: 0

        property string currentTime: Qt.formatDateTime(new Date(), "hh:mm AP  dd MMM")

        Timer {
            id: clockTimer
            interval: 60000
            running: true
            repeat: true
            onTriggered: {
                topBar.currentTime = Qt.formatDateTime(new Date(), "hh:mm AP  dd MMM")
            }
        }

        Image {
            id: background
            source: "qrc:/assets/top_dark.png"
            anchors.fill: parent
            width: parent.width - 455
            height: 51
            fillMode: Image.Stretch
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.centerIn: background
            spacing: 40

            Text {
                text: topBar.currentTime
                color: "black"
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }

            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    source: "qrc:/assets/weather_sunny.png"
                    width: 16
                    height: 16
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    text: "22°C"
                    color: "black"
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MouseArea {
                width: 30
                height: 30
                onClicked: {
                    SystemManager.toggleWifi()
                }
                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: SystemManager.wifiEnabled
                        ? (
                            SystemManager.wifiSignalLevel === 1 ? "qrc:/assets/network-cellular-signal-weak-svgrepo-com.svg" :
                            SystemManager.wifiSignalLevel === 2 ? "qrc:/assets/network-cellular-signal-ok-svgrepo-com.svg" :
                            SystemManager.wifiSignalLevel === 3 ? "qrc:/assets/network-cellular-signal-good-svgrepo-com.svg" :
                            "qrc:/assets/network-cellular-signal-excellent-svgrepo-com.svg"
                        )
                        : "qrc:/assets/network-cellular-signal-none-svgrepo-com.svg"
                }
            }

            MouseArea {
                width: 30
                height: 30
                onClicked: {
                    SystemManager.toggleBluetooth()
                }
                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: SystemManager.bluetoothEnabled
                        ? "qrc:/assets/eva_bluetooth-fill.svg"
                        : "qrc:/assets/bluetooth_icon.png.svg"
                }
            }
        }
    }

    Item {
        anchors.fill: parent

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 100
            spacing: 20

            // Speed display
            Column {
                spacing: 5
                Text {
                    text: "km/h"
                    color: "black"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: currentSpeed
                    color: "black" 
                    font.pixelSize: 72
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            spacing: 60

            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                property int fuelLevel: BusReader.fuelLevel * 100 / 4095
                Item {
                    width: 28
                    height: 28
                    Image {
                        id: fuelIcon
                        anchors.fill: parent
                        source: "qrc:/assets/fuel_pump.svg"
                        fillMode: Image.PreserveAspectFit
                    }
                    MultiEffect {
                        anchors.fill: fuelIcon
                        source: fuelIcon
                        colorization: 1.0
                        colorizationColor: parent.parent.fuelLevel > 67 ? "green" :
                                           parent.parent.fuelLevel > 34 ? "yellow" : "red"
                    }
                }
                Text {
                    text: parent.fuelLevel + "%"
                    color: "black"
                    font.pixelSize: 18
                    font.bold: true
                }
            }

            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                property int batteryLevel: BusReader.batteryLevel * 100 / 4095
                Item {
                    width: 28
                    height: 28
                    Image {
                        id: batteryIcon
                        anchors.fill: parent
                        source: "qrc:/assets/battery.svg"
                        fillMode: Image.PreserveAspectFit
                    }
                    MultiEffect {
                        anchors.fill: batteryIcon
                        source: batteryIcon
                        colorization: 1.0
                        colorizationColor: parent.parent.batteryLevel > 67 ? "green" :
                                           parent.parent.batteryLevel > 34 ? "yellow" : "red"
                    }
                }
                Text {
                    text: parent.batteryLevel + "%"
                    color: "black"
                    font.pixelSize: 18
                    font.bold: true
                }
            }
        }
    }
}