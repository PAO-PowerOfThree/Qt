import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects  // This replaces QtGraphicalEffects in Qt 6
import PaoCluster

ApplicationWindow {
    id: window
    width: 1024
    height: 600
    visible: true
    //flags: Qt.FramelessWindowHint // removes title bar and window buttons
    color: "black" // fallback


    // Background image fills everything
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/assets/paoyalla.jpg"
        fillMode: Image.Stretch
    }
    Item {
           id: topBar
           width: parent.width
           height: 121  // enough to cover topMargin + 51px bar

           // Property for updating time
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

           // Background bar image
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

           // Row of info elements on top of the bar
           Row {

               anchors.centerIn: background
               spacing: 40

               // LEFT INDICATOR
              /* MouseArea {
                   width: 30
                   height: 30
                   onClicked: {
                       topBar.leftIndicatorOn = !topBar.leftIndicatorOn
                       leftBlinkTimer.running = topBar.leftIndicatorOn
                   }

                   Image {
                       id: leftIndicatorImage
                       anchors.fill: parent
                       fillMode: Image.PreserveAspectFit
                       source: topBar.leftIndicatorOn
                           ? "qrc:/assets/icn_leftindicator_glow.svg"
                           : "qrc:/assets/icn_leftindicator.svg"
                       opacity: 1.0
                   }

                   Timer {
                       id: leftBlinkTimer
                       interval: 500  // ms
                       repeat: true
                       running: false
                       onTriggered: {
                           leftIndicatorImage.opacity = leftIndicatorImage.opacity === 1 ? 0.3 : 1
                       }
                   }
               }*/
               // LEFT INDICATOR
                   MouseArea {
                       width: 30
                       height: 30
                       onClicked: BusReader.setLedState(!BusReader.ledState)  // Use context property method
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

               // Time & Date
               Text {
                   text: topBar.currentTime
                   color: "white"
                   font.pixelSize: 16
                   verticalAlignment: Text.AlignVCenter
               }

               // Weather
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

               // Spacer using an invisible Item to push icons to the right
               // Item {
               //     width: 1
               //     height: 1
               //     Layout.fillWidth: true  // This won't work in Row, so we'll use anchors instead
               // }

               // Wi-Fi Icon
               MouseArea
               {
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


               // Bluetooth Icon with Toggle
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
                // RIGHT INDICATOR
               /* MouseArea {
                    width: 30
                    height: 30
                    onClicked: {
                        topBar.rightIndicatorOn = !topBar.rightIndicatorOn
                        rightBlinkTimer.running = topBar.rightIndicatorOn
                    }

                    Image {
                        id: rightIndicatorImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: topBar.rightIndicatorOn
                            ? "qrc:/assets/icn_rightindicatoron.svg"
                            : "qrc:/assets/icn_rightindicator.svg"
                        opacity: 1.0
                    }

                    Timer {
                        id: rightBlinkTimer
                        interval: 500
                        repeat: true
                        running: false
                        onTriggered: {
                            rightIndicatorImage.opacity = rightIndicatorImage.opacity === 1 ? 0.3 : 1
                        }
                    }
                }*/
                // RIGHT INDICATOR
                    MouseArea {
                        width: 30
                        height: 30
                        onClicked: BusReader.setRightIndicatorState(!BusReader.rightIndicatorState)  // Use context property method
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





    // Main UI overlay
    Item {
        anchors.fill: parent

        // Group nav + speed vertically on left
        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 100 // Moved more to the right
            spacing: 20

            // Navigation info (no background)
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
                    anchors.horizontalCenter: parent.horizontalCenter // Center the Column horizontally

                }
                Text {
                    text: "25"
                    color: "white"
                    font.pixelSize: 72
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Bottom control bar

        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            spacing: 30  // tighter spacing

            // Music info (Album cover + Artist)
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter  // Align vertically with parent Row

                Image {
                    width: 32
                    height: 32
                    source: "qrc:/assets/album_cover.png"
                    fillMode: Image.PreserveAspectCrop
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter  // Center the Column vertically

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

            // Self-driving status with up/down
            Column {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter  // Align vertically with parent Row

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

            // Driving mode
            RowLayout {  // Changed from RowLayout to Row for consistency and simpler alignment
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter  // Align vertically with parent Row

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

            // Fuel Level
            /*Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                property int fuelLevel: 66  // Defined in the Row

                // Fuel icon with dynamic color
                Item {
                    width: 28
                    height: 28

                    Image {
                        id: fuelIcon
                        width: 28
                        height: 28
                        source: "qrc:/assets/fuel_pump.svg"
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: fuelIcon
                        source: fuelIcon
                        color: parent.parent.fuelLevel > 67 ? "green" :
                               parent.parent.fuelLevel > 34 ? "yellow" : "red"  // Use parent.parent.batteryLevel
                    }
                }

                Text {
                    text: parent.fuelLevel + "%"  // Use parent.batteryLevel
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }
        }*/

            // Fuel Level
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                property int fuelLevel: BusReader.fuelLevel * 100 / 4095  // Context property

                // Fuel icon with dynamic color
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


            // Battery Level
           /* Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                property int batteryLevel: 100  // Defined in the Row

                // Battery icon with dynamic color
                Item {
                    width: 28
                    height: 28

                    Image {
                        id: batteryIcon
                        width: 28
                        height: 28
                        source: "qrc:/assets/battery.svg"
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: batteryIcon
                        source: batteryIcon
                        color: parent.parent.batteryLevel > 67 ? "green" :
                               parent.parent.batteryLevel > 34 ? "yellow" : "red"  // Use parent.parent.batteryLevel
                    }
                }

                Text {
                    text: parent.batteryLevel + "%"  // Use parent.batteryLevel
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                }
            }*/

                // Battery Level
                Row {
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter

                    property int batteryLevel: BusReader.batteryLevel * 100 / 4095  // Context property

                    // Battery icon with dynamic color
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
                        text:parent.batteryLevel + "%"
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

        }
    }
}
