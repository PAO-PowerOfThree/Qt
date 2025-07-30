#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "serialreader.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    SerialReader serialReader;
    if (!serialReader.openSerialPort()) {
        qWarning("Failed to open serial port");
    }

    engine.rootContext()->setContextProperty("serialReader", &serialReader);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("PAO", "Main");

    return app.exec();
}
