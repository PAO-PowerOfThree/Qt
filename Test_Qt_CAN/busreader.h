#ifndef BUSREADER_H
#define BUSREADER_H

#include <QObject>
#include <QCanBusDevice>
#include <QTimer>

class BusReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool ledState READ ledState NOTIFY ledStateChanged)
    Q_PROPERTY(int batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(int brightness READ brightness NOTIFY brightnessChanged)

public:
    explicit BusReader(QObject *parent = nullptr);
    ~BusReader();

    bool ledState() const { return m_ledState; }
    int batteryLevel() const { return m_batteryLevel; }
    int brightness() const { return m_brightness; }

signals:
    void ledStateChanged();
    void batteryLevelChanged();
    void brightnessChanged();

private slots:
    void readCanData();

private:
    void setLedState(bool state);
    void setBatteryLevel(int level);
    void setBrightness(int value);

    QCanBusDevice *m_canDevice = nullptr;
    QTimer *m_timer = nullptr;

    bool m_ledState = false;
    int m_batteryLevel = 0;
    int m_brightness = 0;
};

#endif // BUSREADER_H
