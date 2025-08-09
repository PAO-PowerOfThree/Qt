import QtQuick
import QtQuick.Layouts

Item {
    width: parent.width
    height: 50

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Item { Layout.fillWidth: true }

        Text {
            text: "08:30"
            font.pixelSize: 18
            font.family: "Georgia"
            font.weight: Font.Medium
            color: "#333"
        }

        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: "#87CEEB"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "☁"
                    font.pixelSize: 12
                    color: "white"
                    anchors.centerIn: parent
                }
            }

            Text {
                text: "26°C"
                font.pixelSize: 18
                font.family: "Georgia"
                font.weight: Font.Medium
                color: "#333"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            text: "ECO"
            font.pixelSize: 18
            font.family: "Georgia"
            font.weight: Font.Bold
            color: "#4CAF50"
        }
    }
}
