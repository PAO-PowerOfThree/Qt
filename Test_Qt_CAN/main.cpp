#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "busreader.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    BusReader busReader;  // create BusReader instance

    // Expose to QML with name "reader"
    engine.rootContext()->setContextProperty("reader", &busReader);

    engine.loadFromModule("PAO_CAN", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
