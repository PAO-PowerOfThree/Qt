import QtQuick

Row {
    spacing: 20

    property string gear: "D"

    Repeater {
        model: ["P", "D", "R", "N"]
        delegate: Text {
            text: modelData
            font.pixelSize: 24
            font.family: "Georgia"
            font.weight: Font.Bold
            color: modelData === gear ? "#333" : "#bbb"
        }
    }
}
