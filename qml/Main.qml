import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    width: 1024
    height: 600
    visible: true
    title: "IVI UI"
    color: "#e7dfd3"

    property bool isDarkMode: false

    Rectangle {
        id: dashboard
        width: 1024
        height: 600
        anchors.centerIn: parent
        radius: 30
        color: "transparent"
        border.color: "#000"
        border.width: 8

        Rectangle {
            anchors.fill: parent
            radius: 20
            clip: true

            Image {
                anchors.fill: parent
                source: isDarkMode ? "qrc:/assets/paoimage_dark.png" : "qrc:/assets/modified_car_image_smaller.png"
                fillMode: Image.PreserveAspectCrop
            }
        }

        // Dark mode toggle button
        Rectangle {
            id: toggleButton
            width: 80
            height: 40
            radius: 20
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 20
            anchors.leftMargin: 20
            color: isDarkMode ? "#333" : "#fff"
            border.color: isDarkMode ? "#555" : "#ccc"
            border.width: 2

            Rectangle {
                id: toggleIndicator
                width: 32
                height: 32
                radius: 16
                color: isDarkMode ? "#fff" : "#333"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: isDarkMode ? undefined : parent.left
                anchors.right: isDarkMode ? parent.right : undefined
                anchors.leftMargin: isDarkMode ? 0 : 4
                anchors.rightMargin: isDarkMode ? 4 : 0

                Behavior on anchors.leftMargin {
                    NumberAnimation { duration: 200 }
                }
                Behavior on anchors.rightMargin {
                    NumberAnimation { duration: 200 }
                }
            }

            Text {
                text: isDarkMode ? "🌙" : "☀️"
                font.pixelSize: 16
                anchors.centerIn: toggleIndicator
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    isDarkMode = !isDarkMode
                }
            }
        }

        // Top status bar
        Row {
            spacing: 30
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 30
            anchors.rightMargin: 50

            Text {
                text: "08:30"
                font.pixelSize: 20
                font.family: "Georgia"
                font.weight: Font.Normal
                color: isDarkMode ? "#fff" : "#333"
            }

            Row {
                spacing: 8
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: "#87CEEB"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "☁"
                        font.pixelSize: 14
                        color: "white"
                        anchors.centerIn: parent
                    }
                }
                Text {
                    text: "26°C"
                    font.pixelSize: 20
                    font.family: "Georgia"
                    font.weight: Font.Normal
                    color: isDarkMode ? "#fff" : "#333"
                }
            }

            Row {
                spacing: 25

                // Fuel indicator
                Column {
                    spacing: 5
                    Image {
                        source: isDarkMode ? "qrc:/assets/fuel_pump_dark.svg" : "qrc:/assets/fuel_pump.svg"
                        width: 30
                        height: 30
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 30
                        sourceSize.height: 30
                    }
                    Text {
                        text: "75%"
                        font.pixelSize: 20
                        font.family: "Georgia"
                        font.weight: Font.Medium
                        color: isDarkMode ? "#fff" : "#333"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Battery indicator
                Column {
                    spacing: 5
                    Image {
                        source: isDarkMode ? "qrc:/assets/battery_dark.svg" : "qrc:/assets/battery.svg"
                        width: 30
                        height: 30
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 30
                        sourceSize.height: 30
                    }
                    Text {
                        text: "90%"
                        font.pixelSize: 20
                        font.family: "Georgia"
                        font.weight: Font.Medium
                        color: isDarkMode ? "#fff" : "#333"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // Gear indicator
        Row {
            spacing: 15
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 50
            anchors.topMargin: 80

            Repeater {
                model: ["P", "D", "R", "N"]
                delegate: Text {
                    text: modelData
                    font.pixelSize: 28
                    font.family: "Georgia"
                    font.weight: Font.Bold
                    color: modelData === "D" ? (isDarkMode ? "#fff" : "#333") : (isDarkMode ? "#666" : "#bbb")
                }
            }
        }

        // Speed display
        Column {
            anchors.left: parent.left
            anchors.top: parent.top
            //anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 25
            anchors.topMargin: 200
            spacing: -15

            Text {
                text: "85"
                font.pixelSize: 125
                font.family: "Georgia"
                font.weight: Font.Bold
                color: isDarkMode ? "#fff" : "#333"
            }
            Text {
                text: "km/h"
                font.pixelSize: 25
                font.family: "Georgia"
                font.weight: Font.Normal
                color: isDarkMode ? "#ccc" : "#666"
                anchors.leftMargin: 50
            }
        }

        // Odometer
        Column {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 25
            anchors.bottomMargin: 50
            spacing: 10

            Text {
                text: "300"
                font.pixelSize: 36
                font.family: "Georgia"
                font.weight: Font.Bold
                color: isDarkMode ? "#fff" : "#333"
            }
            Text {
                text: "km"
                font.pixelSize: 20
                font.family: "Georgia"
                font.weight: Font.Normal
                color: isDarkMode ? "#ccc" : "#666"
            }
        }

        // Navigation info (moved higher)
        Column {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20  // Higher position
            spacing: 5

            Image {
                source: "qrc:/assets/left_arrow.png"
                width: 50
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
            }

            Text {
                text: "3.2"
                font.pixelSize: 36
                font.family: "Georgia"
                font.weight: Font.Bold
                color: isDarkMode ? "#fff" : "#333"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "km"
                font.pixelSize: 18
                font.family: "Georgia"
                font.weight: Font.Normal
                color: isDarkMode ? "#ccc" : "#666"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "King's Road"
                font.pixelSize: 20
                font.family: "Georgia"
                font.weight: Font.Medium
                color: "#B8860B"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // RPM gauge
        Column {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 5
            anchors.topMargin: 200
            spacing: -5

            Text {
                text: "4000"
                font.pixelSize: 102
                font.family: "Georgia"
                font.weight: Font.Bold
                color: isDarkMode ? "#fff" : "#333"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "RPM"
                font.pixelSize: 22
                font.family: "Georgia"
                font.weight: Font.Normal
                color: isDarkMode ? "#ccc" : "#666"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Car view
        CarView {
            id: carView  // Added ID for reference
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
        }
    }
}
