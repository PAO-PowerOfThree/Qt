// ErrorDialog.qml - Unchanged, but ensure it's in qrc:/qml/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dialog
    title: "Error"
    modal: true
    standardButtons: Dialog.Ok

    property string message: ""

    ColumnLayout {
        anchors.fill: parent

        Text {
            text: message
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }

    onAccepted: {
        if (message.includes("serial port")) {
            Qt.quit() // Exit if serial port fails
        }
    }
}