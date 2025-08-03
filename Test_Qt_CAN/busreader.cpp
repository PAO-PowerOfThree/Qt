#include "busreader.h"
#include <QCanBus>
#include <QCanBusFrame>
#include <QDebug>

BusReader::BusReader(QObject *parent) : QObject(parent)
{
    QString errorString;
    m_canDevice = QCanBus::instance()->createDevice("socketcan", "can0", &errorString);
    if (!m_canDevice) {
        qWarning() << "Failed to create CAN device:" << errorString;
        return;
    }

    if (!m_canDevice->connectDevice()) {
        qWarning() << "Failed to connect CAN device:" << m_canDevice->errorString();
        return;
    }

    connect(m_canDevice, &QCanBusDevice::framesReceived, this, &BusReader::readCanData);
}

BusReader::~BusReader()
{
    if (m_canDevice) {
        m_canDevice->disconnectDevice();
        delete m_canDevice;
    }
}

void BusReader::readCanData()
{
    if (!m_canDevice)
        return;

    while (m_canDevice->framesAvailable()) {
        const QCanBusFrame frame = m_canDevice->readFrame();
        if (frame.frameId() == 0x101 && frame.payload().size() == 1) {
            bool state = frame.payload().at(0) != 0;
            setLedState(state);
        } else if (frame.frameId() == 0x102 && frame.payload().size() == 4) {
            int adc = (frame.payload()[0] << 8) | frame.payload()[1];
            int pwm = (frame.payload()[2] << 8) | frame.payload()[3];
            setBatteryLevel(adc);
            setBrightness(pwm);
        }
    }
}

void BusReader::setLedState(bool state)
{
    if (m_ledState != state) {
        m_ledState = state;
        emit ledStateChanged();
    }
}

void BusReader::setBatteryLevel(int level)
{
    if (m_batteryLevel != level) {
        m_batteryLevel = level;
        emit batteryLevelChanged();
    }
}

void BusReader::setBrightness(int value)
{
    if (m_brightness != value) {
        m_brightness = value;
        emit brightnessChanged();
    }
}
