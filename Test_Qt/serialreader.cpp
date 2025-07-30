#include "serialreader.h"
#include <QDebug>

SerialReader::SerialReader(QObject *parent)
    : QObject(parent)
{
    connect(&m_serial, &QSerialPort::readyRead, this, &SerialReader::readData);
}

bool SerialReader::openSerialPort()
{
    m_serial.setPortName("/dev/ttyS0"); //rpi
    //m_serial.setPortName("/dev/ttyUSB0"); //ttl Change to your port
    m_serial.setBaudRate(QSerialPort::Baud115200);
    m_serial.setDataBits(QSerialPort::Data8);
    m_serial.setParity(QSerialPort::NoParity);
    m_serial.setStopBits(QSerialPort::OneStop);
    m_serial.setFlowControl(QSerialPort::NoFlowControl);

    return m_serial.open(QIODevice::ReadOnly);
}

void SerialReader::readData()
{
    while (m_serial.canReadLine()) {
        QByteArray line = m_serial.readLine().trimmed();
        QString receivedData = QString(line);
        if (receivedData.startsWith("Button State:")) {
            bool ok;
            int state = receivedData.split(": ")[1].split("\r")[0].toInt(&ok);
            if (ok && m_buttonState != state) {
                m_buttonState = state;
                emit buttonStateChanged();
            }
        } else if (receivedData.startsWith("Pot ADC:")) {
            QStringList parts = receivedData.split(", ");
            if (parts.size() == 2) {
                bool ok1, ok2;
                int adc = parts[0].split(": ")[1].toInt(&ok1);
                int pwm = parts[1].split(": ")[1].split("\r")[0].toInt(&ok2);
                if (ok1 && ok2) {
                    if (m_adcValue != adc) {
                        m_adcValue = adc;
                        emit adcValueChanged();
                    }
                    if (m_pwmValue != pwm) {
                        m_pwmValue = pwm;
                        emit pwmValueChanged();
                    }
                }
            }
        }
    }
}
