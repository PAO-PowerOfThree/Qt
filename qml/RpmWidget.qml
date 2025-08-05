import QtQuick

Item {
    property int rpm: 4000

    Column {
        anchors.centerIn: parent
        spacing: -10

        Text {
            text: rpm
            font.pixelSize: 105
            font.family: "Georgia"
            font.weight: Font.Bold
            color: "#222"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "RPM"
            font.pixelSize: 22
            font.family: "Georgia"
            font.weight: Font.Normal
            color: "#666"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
