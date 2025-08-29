import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    anchors.fill: parent

    // Property to control bottom buttons visibility
    property bool buttonsVisible: false

    // Modern dark background with gradient
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a2e" }
            GradientStop { position: 0.5; color: "#16213e" }
            GradientStop { position: 1.0; color: "#0f3460" }
        }
    }

// Correct AnimatedImage for Qt6
AnimatedImage {
    id: backgroundAnimation
    anchors.fill: parent
    source: "qrc:/assets/volvo.gif"   // Must exist in your .qrc file
    opacity: 0.3

    Component.onCompleted: {
        // Start the animation safely after the component is ready
        backgroundAnimation.running = true
    }
}


    // Main content overlay
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // Top status bar
        Rectangle {
            id: statusBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 60
            color: "#000000"
            opacity: 0.7
            radius: 0

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#2d2d44" }
                    GradientStop { position: 1.0; color: "#1a1a2e" }
                }
                opacity: 0.9
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: serialManager && serialManager.status.includes("Connected") ? "#4ade80" : "#ef4444"
                }

                Text {
                    id: statusLabel
                    text: serialManager ? serialManager.status : "Initializing..."
                    font.family: "Segoe UI"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#e2e8f0"
                    Layout.fillWidth: true
                }

                Text {
                    text: new Date().toLocaleTimeString()
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    color: "#94a3b8"

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: parent.text = new Date().toLocaleTimeString();
                    }
                }
            }
        }

        // Central circular button
        Item {
            anchors.centerIn: parent
            width: 200
            height: 200

            // Outer glow effect
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 20
                height: parent.height + 20
                radius: (width / 2)
                color: "transparent"
                border.color: "#60a5fa"
                border.width: 2
                opacity: 0.5

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.2; duration: 2000 }
                    NumberAnimation { to: 0.8; duration: 2000 }
                }
            }

            // Main circular button
            Rectangle {
                id: mainButton
                anchors.fill: parent
                radius: width / 2
                color: "#1e40af"
                border.color: "#3b82f6"
                border.width: 3

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#3b82f6" }
                    GradientStop { position: 0.5; color: "#2563eb" }
                    GradientStop { position: 1.0; color: "#1d4ed8" }
                }

                // Fingerprint icon
                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 48
                    color: "#ffffff"
                }

                Text {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 30
                    text: "TAP TO ACCESS"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: "#ffffff"
                    opacity: 0.8
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        buttonsVisible = !buttonsVisible; // toggle bottom buttons
                        scaleAnimation.start();
                        rippleAnimation.start();

                        if (serialManager && serialManager.hasPassword()) {
                            passwordDialog.mode = "verify";
                            passwordDialog.action = "access";
                            passwordDialog.open();
                        } else if (serialManager) {
                            passwordDialog.mode = "set";
                            passwordDialog.open();
                        } else {
                            errorDialog.message = "SerialManager not initialized. Check application setup.";
                            errorDialog.open();
                        }
                    }

                    onPressed: mainButton.scale = 0.95;
                    onReleased: mainButton.scale = 1.0;

                    PropertyAnimation {
                        id: scaleAnimation
                        target: mainButton
                        property: "scale"
                        from: 1.0
                        to: 1.1
                        duration: 100
                        easing.type: Easing.OutQuad

                        onFinished: scaleBackAnimation.start();
                    }

                    PropertyAnimation {
                        id: scaleBackAnimation
                        target: mainButton
                        property: "scale"
                        to: 1.0
                        duration: 100
                        easing.type: Easing.InQuad
                    }
                }
            }

            // Ripple effect
            Rectangle {
                id: ripple
                anchors.centerIn: parent
                width: 0
                height: 0
                radius: width / 2
                color: "#ffffff"
                opacity: 0.3
                visible: false

                ParallelAnimation {
                    id: rippleAnimation

                    NumberAnimation {
                        target: ripple
                        property: "width"
                        from: 0
                        to: 400
                        duration: 600
                        easing.type: Easing.OutQuad
                    }

                    NumberAnimation {
                        target: ripple
                        property: "height"
                        from: 0
                        to: 400
                        duration: 600
                        easing.type: Easing.OutQuad
                    }

                    NumberAnimation {
                        target: ripple
                        property: "opacity"
                        from: 0.3
                        to: 0
                        duration: 600
                        easing.type: Easing.OutQuad
                    }

                    onStarted: ripple.visible = true;
                    onFinished: ripple.visible = false;
                }
            }
        }

        // Bottom action buttons
        Rectangle {
            id: actionButtons
            visible: buttonsVisible
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 100
            color: "#000000"
            opacity: 0.8

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1a1a2e" }
                    GradientStop { position: 1.0; color: "#2d2d44" }
                }
                opacity: 0.9
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // Enroll button
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 25
                    color: "#059669"
                    border.color: "#10b981"
                    border.width: 1

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#10b981" }
                        GradientStop { position: 1.0; color: "#059669" }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "ENROLL FINGERPRINT"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (serialManager) {
                                serialManager.sendEnroll();
                            } else {
                                console.log("serialManager not available");
                            }
                        }

                        onPressed: parent.scale = 0.98;
                        onReleased: parent.scale = 1.0;
                    }
                }

                // Clear button
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 25
                    color: "#dc2626"
                    border.color: "#ef4444"
                    border.width: 1

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ef4444" }
                        GradientStop { position: 1.0; color: "#dc2626" }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "CLEAR ALL"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (serialManager) {
                                serialManager.sendClear();
                            } else {
                                console.log("serialManager not available");
                            }
                        }

                        onPressed: parent.scale = 0.98;
                        onReleased: parent.scale = 1.0;
                    }
                }
            }
        }

        // Log area (collapsible)
        Rectangle {
            id: logArea
            anchors.right: parent.right
            anchors.top: statusBar.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: buttonsVisible ? 100 : 0
            width: logExpanded ? 350 : 40
            color: "#000000"
            opacity: 0.9

            property bool logExpanded: false

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1f2937" }
                    GradientStop { position: 1.0; color: "#111827" }
                }
                opacity: 0.95
            }

            // Toggle button
            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 60
                color: "#374151"
                radius: 8

                Text {
                    anchors.centerIn: parent
                    text: logArea.logExpanded ? "→" : "←"
                    font.pixelSize: 16
                    color: "#e5e7eb"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: logArea.logExpanded = !logArea.logExpanded;
                }
            }

            // Log content
            ScrollView {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 50
                anchors.margins: 10
                visible: logArea.logExpanded

                TextArea {
                    id: logTextArea
                    text: serialManager ? serialManager.log : "Waiting for serial connection..."
                    readOnly: true
                    wrapMode: TextArea.Wrap
                    color: "#e5e7eb"
                    font.family: "Consolas, monospace"
                    font.pixelSize: 10
                    selectByMouse: true

                    background: Rectangle {
                        color: "transparent"
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
        console.log("Fingerprint QML loaded");
        if (serialManager) {
            console.log("serialManager is available");
            if (!serialManager.hasPassword()) {
                passwordDialog.mode = "set";
                passwordDialog.open();
            }
        } else {
            console.log("serialManager is undefined at startup");
            errorDialog.message = "SerialManager not initialized. Check application setup.";
            errorDialog.open();
        }
    }

    Connections {
        target: serialManager
        function onShowError(message) {
            errorDialog.message = message;
            errorDialog.open();
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