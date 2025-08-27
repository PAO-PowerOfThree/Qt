// PasswordDialog.qml - Unchanged, but ensure it's in qrc:/qml/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dialog
    title: mode === "set" ? "Set Password" : "Verify Password"
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel

    property string mode: "verify" // "set" or "verify"
    property string action: ""

    ColumnLayout {
        anchors.fill: parent

        TextField {
            id: passwordField
            placeholderText: "Enter password"
            echoMode: TextInput.Password
            Layout.fillWidth: true
        }

        Label {
            id: errorLabel
            color: "red"
            visible: false
            Layout.fillWidth: true
        }
    }

    onAccepted: {
        if (!serialManager) {
            errorLabel.text = "SerialManager not available"
            errorLabel.visible = true
            console.log("serialManager is null in PasswordDialog")
            open()
            return
        }
        if (mode === "set") {
            if (passwordField.text !== "") {
                serialManager.setPassword(passwordField.text)
            } else {
                errorLabel.text = "Password cannot be empty"
                errorLabel.visible = true
                open()
            }
        } else {
            if (serialManager.verifyPassword(passwordField.text)) {
                serialManager.sendCommand(action)
            } else {
                errorLabel.text = "Incorrect password"
                errorLabel.visible = true
                open()
            }
        }
        passwordField.text = ""
    }

    onRejected: {
        passwordField.text = ""
        errorLabel.visible = false
    }

    Connections {
        target: serialManager
        function onRequestPassword(action) {
            dialog.mode = "verify"
            dialog.action = action
            dialog.open()
        }
    }
}