import QtQuick
import QtQuick.Layouts

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    // Road and car view using generated images
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        width: 300
        height: 200

        // Road background using generated image
        Image {
            source: "qrc:/assets/road.png"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }

        // Car image using generated image
        Image {
            source: "qrc:/assets/car_back.png"
            width: 100
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            fillMode: Image.PreserveAspectFit
        }
    }
}
