import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dialog
    modal: true
    // Add these properties to make the dialog properly centered
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 380
    height: 280

    property string message: ""

    // Remove default background
    background: Item {}

    // Custom overlay
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.7

        MouseArea {
            anchors.fill: parent
            onClicked: dialog.accept();
        }
    }

    // Modern error dialog container
    Rectangle {
        id: dialogContainer
        anchors.fill: parent
        radius: 20
        color: "#ffffff"

        // Gradient background
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#fef2f2" }
                GradientStop { position: 1.0; color: "#fee2e2" }
            }
        }

        // Drop shadow simulation
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
            spacing: 20

            // Error icon
            Rectangle {
                id: errorIcon
                Layout.alignment: Qt.AlignHCenter
                width: 70
                height: 70
                radius: 35
                color: "#dc2626"

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f87171" }
                    GradientStop { position: 1.0; color: "#dc2626" }
                }

                Text {
                    anchors.centerIn: parent
                    text: "⚠️"
                    font.pixelSize: 32
                }

                // Error pulse animation
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.1; duration: 800; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                }
            }

            // Title
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Error"
                font.family: "Segoe UI"
                font.pixelSize: 20
                font.weight: Font.Bold
                color: "#991b1b"
            }

            // Error message
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#ffffff"
                border.color: "#fca5a5"
                border.width: 1

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 15

                    Text {
                        text: message
                        wrapMode: Text.Wrap
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                        color: "#7f1d1d"
                        width: parent.width
                    }
                }
            }

            // OK button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                radius: 12
                color: "#dc2626"

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f87171" }
                    GradientStop { position: 1.0; color: "#dc2626" }
                }

                Text {
                    anchors.centerIn: parent
                    text: "OK"
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

        // Enter animation
        NumberAnimation on scale {
            from: 0.7
            to: 1.0
            duration: 400
            easing.type: Easing.OutBack
            running: dialog.visible
        }

        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 300
            running: dialog.visible
        }
    }

    onAccepted: {
        if (message.includes("serial port")) {
            Qt.quit();
        }
    }

    // Shake animation for critical errors
    SequentialAnimation {
        id: shakeAnimation
        running: dialog.visible && message.includes("critical")
        NumberAnimation { target: dialogContainer; property: "x"; to: dialogContainer.x + 15; duration: 100 }
        NumberAnimation { target: dialogContainer; property: "x"; to: dialogContainer.x - 15; duration: 100 }
        NumberAnimation { target: dialogContainer; property: "x"; to: dialogContainer.x + 15; duration: 100 }
        NumberAnimation { target: dialogContainer; property: "x"; to: dialogContainer.x; duration: 100 }
    }
}