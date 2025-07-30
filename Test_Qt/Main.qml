import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PAO

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "STM32 Monitor"

    Rectangle {
        anchors.fill: parent
        color: "#222"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Rectangle {
                id: ledIndicator
                width: 50
                height: 50
                radius: 25
                color: serialReader.buttonState === 1 ? "green" : "red"
                border.color: "white"
                border.width: 2
                Layout.alignment: Qt.AlignHCenter
                Text {
                    anchors.centerIn: parent
                    text: "LED"
                    color: "white"
                    font.bold: true
                }
            }

            Text {
                text: "ADC: " + (serialReader ? serialReader.adcValue : "N/A")
                color: "white"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            ProgressBar {
                from: 0
                to: 4095
                value: serialReader ? serialReader.adcValue : 0
                Layout.preferredWidth: 250
                opacity: serialReader ? (serialReader.pwmValue / 1000.0) : 0.3
            }

            Text {
                text: "PWM: " + (serialReader ? serialReader.pwmValue : "N/A")
                color: "white"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Connections {
        target: serialReader
        function onButtonStateChanged() {
            ledIndicator.color = serialReader.buttonState === 1 ? "green" : "red";
        }
        function onAdcValueChanged() {
            // ADC value updates progress bar value
        }
        function onPwmValueChanged() {
            // PWM value updates progress bar opacity
        }
    }
}
