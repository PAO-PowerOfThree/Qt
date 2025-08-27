// Fingerprint.qml - Content from the original fingerprint Main.qml, adapted for integration
// (Remove ApplicationWindow, add logic for approval/refusal and view switching)
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Text {
            id: statusLabel
            text: serialManager ? "Status: " + serialManager.status : "Status: Initializing..."
            font.bold: true
            font.pixelSize: 16
            Layout.fillWidth: true
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextArea {
                id: logTextArea
                text: serialManager ? serialManager.log : "Waiting for serial connection..."
                readOnly: true
                wrapMode: TextArea.Wrap
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "Enroll Fingerprint"
                Layout.fillWidth: true
                onClicked: {
                    if (serialManager) {
                        serialManager.sendEnroll()
                    } else {
                        console.log("serialManager not available")
                    }
                }
            }

            Button {
                text: "Clear All Fingerprints"
                Layout.fillWidth: true
                onClicked: {
                    if (serialManager) {
                        serialManager.sendClear()
                    } else {
                        console.log("serialManager not available")
                    }
                }
            }
        }
    }

    Text {
        id: messageText
        anchors.centerIn: parent
        text: ""
        color: "red"
        font.pixelSize: 24
        font.bold: true
        visible: false
    }

    Timer {
        id: messageTimer
        interval: 3000
        repeat: false
        onTriggered: messageText.visible = false
    }

    PasswordDialog {
        id: passwordDialog
    }

    ErrorDialog {
        id: errorDialog
    }

    Component.onCompleted: {
        console.log("Fingerprint QML loaded")
        if (serialManager) {
            console.log("serialManager is available")
            if (!serialManager.hasPassword()) {
                passwordDialog.mode = "set"
                passwordDialog.open()
            }
        } else {
            console.log("serialManager is undefined at startup")
            errorDialog.message = "SerialManager not initialized. Check application setup."
            errorDialog.open()
        }
    }

    Connections {
        target: serialManager
        function onStatusChanged() {
            // Keep for updating statusLabel, no navigation here
        }

        function onShowError(message) {
            errorDialog.message = message
            errorDialog.open()
        }

        function onAccessGranted() {
            // Approved: Switch to cluster view
            window.currentView = "cluster"
        }

        function onAccessRefused() {
            // Refused: Show message
            messageText.color = "red"
            messageText.text = "Access Refused"
            messageText.visible = true
            messageTimer.start()
        }

        function onEnrolledSuccess() {
            // Show enrollment success message
            messageText.color = "green"
            messageText.text = "Enrollment Successful"
            messageText.visible = true
            messageTimer.start()
        }
    }
}