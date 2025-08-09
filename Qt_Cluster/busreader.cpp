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
            bool state = frame.payload().at(0) != 0; // Left Indicator
            setLedState(state);
        } else if (frame.frameId() == 0x102 && frame.payload().size() == 4) {
            int adc = (frame.payload()[0] << 8) | frame.payload()[1]; // Battery ADC
            int pwm = (frame.payload()[2] << 8) | frame.payload()[3]; // Battery PWM
            setBatteryLevel(adc);
            setBrightness(pwm);
        } else if (frame.frameId() == 0x103 && frame.payload().size() == 1) {
            bool state = frame.payload().at(0) != 0; // Right Indicator
            setRightIndicatorState(state);
        } else if (frame.frameId() == 0x104 && frame.payload().size() == 4) {
            int adc = (frame.payload()[0] << 8) | frame.payload()[1]; // Fuel ADC
            int pwm = (frame.payload()[2] << 8) | frame.payload()[3]; // Fuel PWM
            setFuelLevel(adc);
            setFuelBrightness(pwm);
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
        m_batteryLevel = qBound(0, level, 4095); // Clamp to ADC range (0-4095)
        emit batteryLevelChanged();
    }
}

void BusReader::setBrightness(int value)
{
    if (m_brightness != value) {
        m_brightness = qBound(0, value, 1000); // Clamp to PWM range (0-1000)
        emit brightnessChanged();
    }
}

void BusReader::setFuelLevel(int level)
{
    if (m_fuelLevel != level) {
        m_fuelLevel = qBound(0, level, 4095); // Clamp to ADC range (0-4095)
        emit fuelLevelChanged();
    }
}

void BusReader::setFuelBrightness(int value)
{
    if (m_fuelBrightness != value) {
        m_fuelBrightness = qBound(0, value, 1000); // Clamp to PWM range (0-1000)
        emit fuelBrightnessChanged();
    }
}

void BusReader::setRightIndicatorState(bool state)
{
    if (m_rightIndicatorState != state) {
        m_rightIndicatorState = state;
        emit rightIndicatorStateChanged();
    }
}
