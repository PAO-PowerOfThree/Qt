#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "systemmanager.h"
#include "busreader.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Instantiate BusReader and set it as a context property
    BusReader *busReader = new BusReader(&app); // Parent app for proper cleanup
    engine.rootContext()->setContextProperty("BusReader", busReader);

    // Register SystemManager as a singleton
    engine.rootContext()->setContextProperty("SystemManager", SystemManager::instance());

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
