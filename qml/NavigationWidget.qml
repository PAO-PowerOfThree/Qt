import QtQuick
import QtQuick.Controls

Item {
    width: 300
    height: 300

    Column {
        anchors.centerIn: parent
        anchors.top: parent
        spacing: 8

        // Left turn arrow using generated image
        Image {
            source: "qrc:/assets/left_arrow.png"
            width: 80
            height: 80
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
        }

        Text {
            text: "3.2"
            font.pixelSize: 50
            font.family: "Georgia"
            font.weight: Font.Bold
            color: "#333"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "km"
            font.pixelSize: 20
            font.family: "Georgia"
            font.weight: Font.Normal
            color: "#666"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "King's Road"
            font.pixelSize: 18
            font.family: "Georgia"
            font.weight: Font.Medium
            color: "#B8860B"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
