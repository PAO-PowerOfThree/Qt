#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTimer>
#include "systemmanager.h"
#include "busreader.h"
#include "client.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Instantiate BusReader and set it as a context property
    BusReader *busReader = new BusReader(&app); // Parent app for proper cleanup
    engine.rootContext()->setContextProperty("BusReader", busReader);

    // Register SystemManager as a singleton
    engine.rootContext()->setContextProperty("SystemManager", SystemManager::instance());

    // Instantiate VSomeIPClient and set it as a context property
    VSomeIPClient vsomeipClient;
    engine.rootContext()->setContextProperty("vsomeipClient", &vsomeipClient);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    // Start the SOME/IP client after QML is loaded
    QTimer::singleShot(0, [&vsomeipClient]() {
        vsomeipClient.startClient();
    });

    return app.exec();
}