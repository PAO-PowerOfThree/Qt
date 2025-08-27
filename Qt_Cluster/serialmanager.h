// serialmanager.h - Updated with setVSomeIPClient
#ifndef SERIALMANAGER_H
#define SERIALMANAGER_H

#include <QObject>
#include <QSerialPort>
#include <QCryptographicHash>
#include <QFile>
#include <QDir>
#include "client.hpp"  // Include VSomeIPClient header for integration

class SerialManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString log READ log NOTIFY logChanged)

public:
    explicit SerialManager(QObject *parent = nullptr);
    ~SerialManager();

    QString status() const { return m_status; }
    QString log() const { return m_log; }

    Q_INVOKABLE void sendCommand(const QString &cmd); // Moved to public and made Q_INVOKABLE

    void setVSomeIPClient(VSomeIPClient *client);

public slots:
    void sendEnroll();
    void sendClear();
    bool verifyPassword(const QString &password);
    bool hasPassword();
    void setPassword(const QString &password);

signals:
    void statusChanged();
    void logChanged();
    void requestPassword(const QString &action);
    void showError(const QString &message);
    void accessGranted();
    void accessRefused();
    void enrolledSuccess();

private slots:
    void readSerialData();

private:
    QSerialPort *m_serial;
    QString m_status;
    QString m_log;
    QByteArray m_passwordHash;
    VSomeIPClient *m_vsomeipClient;  // New: Pointer to VSomeIPClient for sending status to AOSP
    QString m_buffer;

    void setupSerial();
    void appendLog(const QString &message);
    void loadPassword();
};

#endif // SERIALMANAGER_H