import QtQuick
import QtQuick.Controls

Item {
    width: 200
    height: 200

    Column {
        anchors.centerIn: parent
        spacing: 12

        // Album art shadow
        Rectangle {
            width: 124
            height: 124
            radius: 15
            color: "#30000000"
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0.3
        }

        Rectangle {
            id: albumArt
            width: 120
            height: 120
            radius: 15
            color: "#ddd"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: -124

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "#8B4513"

                // Simulated album cover
                Rectangle {
                    width: 80
                    height: 80
                    radius: 8
                    color: "#654321"
                    anchors.centerIn: parent

                    Text {
                        text: "♪"
                        font.pixelSize: 24
                        color: "white"
                        anchors.centerIn: parent
                    }
                }
            }

            // Vinyl record overlay
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: "#333"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 8

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: "#666"
                    anchors.centerIn: parent
                }
            }
        }

        Text {
            text: "We Don't Talk Anymore"
            font.pixelSize: 16
            font.family: "Georgia"
            font.weight: Font.Medium
            color: "#333"
            wrapMode: Text.WordWrap
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Charlie Puth"
            font.pixelSize: 14
            font.family: "Georgia"
            font.weight: Font.Normal
            color: "#777"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
