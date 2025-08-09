#ifndef BUSREADER_H
#define BUSREADER_H

#include <QObject>
#include <QCanBusDevice>
#include <QTimer>

class BusReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool ledState READ ledState NOTIFY ledStateChanged)    // Left Indicator
    Q_PROPERTY(int batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)  // Battery Level
    Q_PROPERTY(int brightness READ brightness NOTIFY brightnessChanged)  // Battery PWM
    Q_PROPERTY(int fuelLevel READ fuelLevel NOTIFY fuelLevelChanged)     // Fuel Level
    Q_PROPERTY(int fuelBrightness READ fuelBrightness NOTIFY fuelBrightnessChanged)  // Fuel PWM
    Q_PROPERTY(bool rightIndicatorState READ rightIndicatorState NOTIFY rightIndicatorStateChanged)  // Right Indicator

public:
    explicit BusReader(QObject *parent = nullptr);
    ~BusReader();

    bool ledState() const { return m_ledState; }
    int batteryLevel() const { return m_batteryLevel; }
    int brightness() const { return m_brightness; }
    int fuelLevel() const { return m_fuelLevel; }
    int fuelBrightness() const { return m_fuelBrightness; }
    bool rightIndicatorState() const { return m_rightIndicatorState; }

signals:
    void ledStateChanged();
    void batteryLevelChanged();
    void brightnessChanged();
    void fuelLevelChanged();
    void fuelBrightnessChanged();
    void rightIndicatorStateChanged();

private slots:
    void readCanData();

private:
    void setLedState(bool state);
    void setBatteryLevel(int level);
    void setBrightness(int value);
    void setFuelLevel(int level);
    void setFuelBrightness(int value);
    void setRightIndicatorState(bool state);

    QCanBusDevice *m_canDevice = nullptr;
    QTimer *m_timer = nullptr;

    bool m_ledState = false;        // Left Indicator state
    int m_batteryLevel = 0;         // Battery ADC level
    int m_brightness = 0;           // Battery PWM
    int m_fuelLevel = 0;            // Fuel ADC level
    int m_fuelBrightness = 0;       // Fuel PWM
    bool m_rightIndicatorState = false;  // Right Indicator state
};
#endif // BUSREADER_H
