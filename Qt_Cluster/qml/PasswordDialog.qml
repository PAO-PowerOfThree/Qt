import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Dialog {
    id: dialog
    modal: true
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 400
    height: 320

    property string mode: "verify" // "set" or "verify"
    property string action: ""

    background: Item {}

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.7

        MouseArea {
            anchors.fill: parent
            onClicked: dialog.reject();
        }
    }

    Rectangle {
        id: dialogContainer
        anchors.fill: parent
        radius: 20
        color: "#ffffff"

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#f8fafc" }
                GradientStop { position: 1.0; color: "#e2e8f0" }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffffff" }
                GradientStop { position: 0.3; color: "#f1f5f9" }
                GradientStop { position: 1.0; color: "#e2e8f0" }
            }
            opacity: 0.8
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -5
            radius: parent.radius + 5
            color: "#000000"
            opacity: 0.1
            z: -1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 25

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Rectangle {
                    id: iconBackground
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: 60
                    height: 60
                    radius: 30
                    color: mode === "set" ? "#3b82f6" : "#10b981"

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: mode === "set" ? "#60a5fa" : "#34d399" }
                        GradientStop { position: 1.0; color: mode === "set" ? "#2563eb" : "#059669" }
                    }

                    // Removed emoji text
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.pixelSize: 24
                    }

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.1; duration: 1000; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: mode === "set" ? "Set New Password" : "Enter Password"
                    font.family: "Segoe UI"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: "#1f2937"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 12
                    color: "#ffffff"
                    border.color: passwordField.activeFocus ? "#3b82f6" : "#d1d5db"
                    border.width: 2

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2
                        radius: parent.radius + 2
                        color: "transparent"
                        border.color: passwordField.activeFocus ? "#3b82f6" : "transparent"
                        border.width: 1
                        opacity: 0.3
                        z: -1
                    }

                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 15
                        placeholderText: "Enter your password"
                        echoMode: showPassword ? TextInput.Normal : TextInput.Password
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                        color: "#1f2937"

                        property bool showPassword: false

                        background: Rectangle {
                            color: "transparent"
                        }

                        Keys.onReturnPressed: dialog.accept();
                        Keys.onEnterPressed: dialog.accept();
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 10
                        width: 30
                        height: 30
                        radius: 15
                        color: passwordField.showPassword ? "#3b82f6" : "#9ca3af"

                        // Removed emoji eye
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: passwordField.showPassword = !passwordField.showPassword;
                        }
                    }
                }

                Rectangle {
                    id: errorContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: errorLabel.visible ? 30 : 0
                    radius: 8
                    color: "#fef2f2"
                    border.color: "#fca5a5"
                    border.width: 1
                    visible: errorLabel.visible

                    Behavior on Layout.preferredHeight {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }

                    Text {
                        id: errorLabel
                        anchors.centerIn: parent
                        color: "#dc2626"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        visible: false
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 15

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    radius: 12
                    color: "#f3f4f6"
                    border.color: "#d1d5db"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#6b7280"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dialog.reject();
                        onPressed: parent.scale = 0.98;
                        onReleased: parent.scale = 1.0;
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    radius: 12
                    color: mode === "set" ? "#3b82f6" : "#10b981"

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: mode === "set" ? "#60a5fa" : "#34d399" }
                        GradientStop { position: 1.0; color: mode === "set" ? "#2563eb" : "#059669" }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: mode === "set" ? "Set Password" : "Unlock"
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dialog.accept();
                        onPressed: parent.scale = 0.98;
                        onReleased: parent.scale = 1.0;
                    }
                }
            }
        }

        NumberAnimation on scale {
            id: enterAnimation
            from: 0.8
            to: 1.0
            duration: 300
            easing.type: Easing.OutBack
            running: dialog.visible
        }

        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 200
            running: dialog.visible
        }
    }

    onAccepted: {
        if (!serialManager) {
            errorLabel.text = "SerialManager not available";
            errorLabel.visible = true;
            console.log("serialManager is null in PasswordDialog");
            open();
            return;
        }

        if (mode === "set") {
            if (passwordField.text !== "") {
                serialManager.setPassword(passwordField.text);
                successAnimation.start();
            } else {
                errorLabel.text = "Password cannot be empty";
                errorLabel.visible = true;
                shakeAnimation.start();
                open();
            }
        } else {
            if (serialManager.verifyPassword(passwordField.text)) {
                serialManager.sendCommand(action);
                successAnimation.start();
            } else {
                errorLabel.text = "Incorrect password";
                errorLabel.visible = true;
                shakeAnimation.start();
                open();
            }
        }

        passwordField.text = "";
    }

    onRejected: {
        passwordField.text = "";
        errorLabel.visible = false;
    }

    onOpened: {
        passwordField.forceActiveFocus();
        errorLabel.visible = false;
    }

    SequentialAnimation {
        id: successAnimation
        NumberAnimation { target: iconBackground; property: "scale"; to: 1.3; duration: 200 }
        NumberAnimation { target: iconBackground; property: "scale"; to: 1.0; duration: 200 }
    }

    SequentialAnimation {
        id: shakeAnimation
        NumberAnimation { target: dialogContainer; property: "x"; to: dialogContainer.x + 10; duration: 50 }
        NumberAnimation { target: dialogContainer; property: "x"; to: dialogContainer.x - 10; duration: 50 }
        NumberAnimation { target: dialogContainer; property: "x"; to: dialogContainer.x + 10; duration: 50 }
        NumberAnimation { target: dialogContainer; property: "x"; to: dialogContainer.x; duration: 50 }
    }

    Connections {
        target: serialManager
        function onRequestPassword(action) {
            dialog.mode = "verify";
            dialog.action = action;
            dialog.open();
        }
    }
}
