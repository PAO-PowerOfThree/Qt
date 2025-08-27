// serialmanager.cpp - Updated to match FakeVehicleHardware: Send "APPROVED" or "REFUSED" (uppercase) to align with AOSP's string check in updateFingerprintProperty
#include "serialmanager.h"
#include <QDebug>

SerialManager::SerialManager(QObject *parent)
    : QObject(parent), m_serial(new QSerialPort(this)), m_vsomeipClient(nullptr), m_buffer("")
{
    setupSerial();
    loadPassword();
}

SerialManager::~SerialManager()
{
    m_serial->close();
}

void SerialManager::setVSomeIPClient(VSomeIPClient *client)
{
    m_vsomeipClient = client;
}

void SerialManager::setupSerial()
{
    // Use /dev/ttyUSB0 for Linux PC testing, adjust for Windows (e.g., COM3)
    // For RPi/Yocto, use the appropriate UART port, e.g., /dev/ttyS0 or /dev/serial0
    m_serial->setPortName("/dev/ttyS0"); // Change to /dev/ttyS0 on RPi/Yocto if needed
    m_serial->setBaudRate(QSerialPort::Baud57600);
    m_serial->setDataBits(QSerialPort::Data8);
    m_serial->setParity(QSerialPort::NoParity);
    m_serial->setStopBits(QSerialPort::OneStop);
    m_serial->setFlowControl(QSerialPort::NoFlowControl);

    qDebug() << "Attempting to open serial port:" << m_serial->portName();
    if (m_serial->open(QIODevice::ReadWrite)) {
        appendLog("Connected to ESP32");
        qDebug() << "Serial port opened successfully";
        connect(m_serial, &QSerialPort::readyRead, this, &SerialManager::readSerialData);
    } else {
        appendLog("Failed to open serial port (testing on PC)");
        qDebug() << "Serial port error:" << m_serial->errorString();
        emit showError("Failed to open serial port. Running in test mode.");
        // Don’t exit, allow UI testing
    }
}

void SerialManager::readSerialData()
{
    QByteArray data = m_serial->readAll();
    m_buffer += QString::fromUtf8(data);

    QStringList lines = m_buffer.split("\r\n");
    for (int i = 0; i < lines.size() - 1; ++i) {
        QString line = lines[i].trimmed();
        if (line.isEmpty()) continue;

        appendLog(line);

        // Parse status
        if (line.contains("[STATUS:")) {
            int start = line.indexOf("[STATUS:") + 8;
            int end = line.indexOf("]", start);
            if (end > start) {
                m_status = line.mid(start, end - start).trimmed();
                qDebug() << "Status updated:" << m_status;
                emit statusChanged();
            }
        }

        // Map fingerprint events to "APPROVED"/"REFUSED" based on actual ESP32 messages
        QString fingerStatus;
        if (line.contains("FINGERPRINT ENROLLED SUCCESSFULLY") || line.contains("ACCESS GRANTED")) {
            fingerStatus = "APPROVED";
        } else if (line.contains("Fingerprint not recognized")) {
            fingerStatus = "REFUSED";
        }
        if (!fingerStatus.isEmpty()) {
            appendLog("Sending fingerprint status to AOSP: " + fingerStatus);
            if (m_vsomeipClient) {
                m_vsomeipClient->sendFingerprintStatus(fingerStatus);
            }
        }

        // Emit specific signals for UI logic
        if (line.contains("ACCESS GRANTED")) {
            emit accessGranted();
        }
        if (line.contains("Fingerprint not recognized")) {
            emit accessRefused();
        }
        if (line.contains("FINGERPRINT ENROLLED SUCCESSFULLY")) {
            emit enrolledSuccess();
        }
    }
    m_buffer = lines.last();
}

void SerialManager::sendEnroll()
{
    qDebug() << "Requesting enroll";
    emit requestPassword("ENROLL");
}

void SerialManager::sendClear()
{
    qDebug() << "Requesting clear";
    emit requestPassword("CLEAR");
}

void SerialManager::sendCommand(const QString &cmd)
{
    m_serial->write((cmd + "\n").toUtf8());
    appendLog("[SENT] " + cmd);
    qDebug() << "Sent command:" << cmd;
}

bool SerialManager::verifyPassword(const QString &password)
{
    QByteArray inputHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
    bool result = inputHash == m_passwordHash;
    qDebug() << "Password verification:" << (result ? "Success" : "Failed");
    return result;
}

bool SerialManager::hasPassword()
{
    bool result = !m_passwordHash.isEmpty();
    qDebug() << "Has password:" << result;
    return result;
}

void SerialManager::setPassword(const QString &password)
{
    QString hashFilePath = QDir::homePath() + "/.fingerprint_app/password.hash";
    QDir().mkpath(QDir::homePath() + "/.fingerprint_app");

    m_passwordHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
    QFile hashFile(hashFilePath);
    if (hashFile.open(QIODevice::WriteOnly)) {
        hashFile.write(m_passwordHash);
        hashFile.close();
        appendLog("Password set successfully");
        qDebug() << "Password saved to" << hashFilePath;
    } else {
        appendLog("Failed to save password");
        qDebug() << "Failed to save password to" << hashFilePath;
        emit showError("Failed to save password to file.");
    }
}

void SerialManager::loadPassword()
{
    QString hashFilePath = QDir::homePath() + "/.fingerprint_app/password.hash";
    QFile hashFile(hashFilePath);
    if (hashFile.exists() && hashFile.open(QIODevice::ReadOnly)) {
        m_passwordHash = hashFile.readAll();
        hashFile.close();
        qDebug() << "Password loaded from" << hashFilePath;
    } else {
        qDebug() << "No password file found at" << hashFilePath;
    }
}

void SerialManager::appendLog(const QString &message)
{
    m_log += message + "\n";
    qDebug() << "Log appended:" << message;
    emit logChanged();
}