// SystemManager.cpp
#include "systemmanager.h"
#include <QRandomGenerator>

SystemManager* SystemManager::instance() {
    static SystemManager inst;
    return &inst;
}

SystemManager::SystemManager(QObject* parent)
    : QObject(parent) {}

bool SystemManager::wifiEnabled() const {
    return m_wifiEnabled;
}

int SystemManager::wifiSignalLevel() const {
    return m_wifiEnabled ? m_wifiSignalLevel : 0;
}

bool SystemManager::bluetoothEnabled() const {
    return m_bluetoothEnabled;
}

void SystemManager::toggleWifi() {
    m_wifiEnabled = !m_wifiEnabled;
    if (m_wifiEnabled) {
        m_wifiSignalLevel = QRandomGenerator::global()->bounded(1, 5); // 1 to 4
    } else {
        m_wifiSignalLevel = 0;
    }
    emit wifiChanged();
}

void SystemManager::toggleBluetooth() {
    m_bluetoothEnabled = !m_bluetoothEnabled;
    emit bluetoothChanged();
}
