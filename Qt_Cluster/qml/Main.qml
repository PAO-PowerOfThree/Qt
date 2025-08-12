import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import PaoCluster

ApplicationWindow {
    id: window
    width: 1024
    height: 600
    visible: true
    visibility: "FullScreen"
    color: "black"

    // Property to hold the current speed
    property string currentSpeed: "0"
    property bool serverAvailable: false

    // Background image fills everything
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/assets/paoyalla.jpg"
        fillMode: Image.Stretch
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
        height: 121

        property string currentTime: Qt.formatDateTime(new Date(), "hh:mm AP  dd MMM")
        property bool leftIndicatorOn: false
        property bool rightIndicatorOn: false

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
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 70.5
            width: parent.width - 455
            height: 51
            fillMode: Image.Stretch
        }

        Row {
            anchors.centerIn: background
            spacing: 40

            MouseArea {
                width: 30
                height: 30
                onClicked: BusReader.setLedState(!BusReader.ledState)
                Image {
                    id: leftIndicatorImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: BusReader.ledState
                        ? "qrc:/assets/icn_leftindicator_glow.svg"
                        : "qrc:/assets/icn_leftindicator.svg"
                    opacity: 1.0
                }
                Timer {
                    id: leftBlinkTimer
                    interval: 500
                    repeat: true
                    running: BusReader.ledState
                    onTriggered: leftIndicatorImage.opacity = leftIndicatorImage.opacity === 1 ? 0.3 : 1
                }
            }

            Text {
                text: topBar.currentTime
                color: "white"
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
                    color: "white"
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

            MouseArea {
                width: 30
                height: 30
                onClicked: BusReader.setRightIndicatorState(!BusReader.rightIndicatorState)
                Image {
                    id: rightIndicatorImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: BusReader.rightIndicatorState
                        ? "qrc:/assets/icn_rightindicatoron.svg"
                        : "qrc:/assets/icn_rightindicator.svg"
                    opacity: 1.0
                }
                Timer {
                    id: rightBlinkTimer
                    interval: 500
                    repeat: true
                    running: BusReader.rightIndicatorState
                    onTriggered: rightIndicatorImage.opacity = rightIndicatorImage.opacity === 1 ? 0.3 : 1
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

            Column {
                spacing: 20

                Row {
                    spacing: 10
                    Rectangle {
                        width: 30
                        height: 30
                        color: "#4a90e2"
                        radius: 5
                        Text {
                            anchors.centerIn: parent
                            text: "↗"
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }

                    Column {
                        Text {
                            text: "1.5 km"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Text {
                            text: "Grand road avenue"
                            color: "#dddddd"
                            font.pixelSize: 12
                        }
                    }
                }

                Row {
                    spacing: 15
                    Text {
                        text: "← 44 min"
                        color: "black"
                        font.pixelSize: 12
                    }
                    Text {
                        text: "↗ 12:44"
                        color: "black"
                        font.pixelSize: 12
                    }
                    Text {
                        text: "⚡ 89 km"
                        color: "black"
                        font.pixelSize: 12
                    }
                }
            }

            // Speed display
            Column {
                spacing: 5
                Text {
                    text: "km/h"
                    color: "white"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: currentSpeed
                    color: "#FFFFFF" 
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
            spacing: 30

            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    width: 32
                    height: 32
                    source: "qrc:/assets/album_cover.png"
                    fillMode: Image.PreserveAspectCrop
                }
                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: "▶"
                        color: "white"
                        font.pixelSize: 14
                    }
                    Text {
                        text: "Bon Jovi"
                        color: "white"
                        font.pixelSize: 10
                    }
                }
            }

            Column {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: "▲"
                    color: "white"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "Self driving"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "▼"
                    color: "white"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            RowLayout {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: "D"
                    color: "white"
                    font.pixelSize: 24
                    font.bold: true
                }
                Text {
                    text: "NORMAL"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

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
                    color: "white"
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
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }
            }
        }
    }
}