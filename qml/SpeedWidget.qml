import QtQuick

Item {
    property int speed: 85

    Column {
        anchors.centerIn: parent
        spacing: -10

        Text {
            text: speed
            font.pixelSize: 105
            font.family: "Georgia"
            font.weight: Font.Bold
            color: "#222"
        }

        Text {
            text: "km/h"
            font.pixelSize: 22
            font.family: "Georgia"
            font.weight: Font.Normal
            color: "#666"
        }
    }
}
