// SystemManager.h
#pragma once

#include <QObject>

class SystemManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool wifiEnabled READ wifiEnabled NOTIFY wifiChanged)
    Q_PROPERTY(int wifiSignalLevel READ wifiSignalLevel NOTIFY wifiChanged)
    Q_PROPERTY(bool bluetoothEnabled READ bluetoothEnabled NOTIFY bluetoothChanged)

public:
    static SystemManager* instance();

    bool wifiEnabled() const;
    int wifiSignalLevel() const;
    bool bluetoothEnabled() const;

    Q_INVOKABLE void toggleWifi();
    Q_INVOKABLE void toggleBluetooth();

signals:
    void wifiChanged();
    void bluetoothChanged();

private:
    explicit SystemManager(QObject* parent = nullptr);

    bool m_wifiEnabled = false;
    int m_wifiSignalLevel = 0;
    bool m_bluetoothEnabled = false;
};
