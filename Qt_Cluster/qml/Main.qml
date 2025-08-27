// Main.qml - Integrated QML with Loader for switching views
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import PaoCluster

ApplicationWindow {
    id: window
    width: 600
    height: 400
    visible: true
    color: "black"
    title: "Pao Cluster"

    property string currentView: "fingerprint"  // Start with fingerprint view

    Loader {
        id: viewLoader
        anchors.fill: parent
        source: currentView === "fingerprint" ? "qrc:/qml/Fingerprint.qml" : "qrc:/qml/Cluster.qml"
    }
}