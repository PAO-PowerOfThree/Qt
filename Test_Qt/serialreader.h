#ifndef SERIALREADER_H
#define SERIALREADER_H

#include <QObject>
#include <QSerialPort>

class SerialReader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int buttonState READ buttonState NOTIFY buttonStateChanged)
    Q_PROPERTY(int adcValue READ adcValue NOTIFY adcValueChanged)
    Q_PROPERTY(int pwmValue READ pwmValue NOTIFY pwmValueChanged)

public:
    explicit SerialReader(QObject *parent = nullptr);
    bool openSerialPort();

    int buttonState() const { return m_buttonState; }
    int adcValue() const { return m_adcValue; }
    int pwmValue() const { return m_pwmValue; }

signals:
    void buttonStateChanged();
    void adcValueChanged();
    void pwmValueChanged();

private slots:
    void readData();

private:
    QSerialPort m_serial;
    int m_buttonState = 0;
    int m_adcValue = 0;
    int m_pwmValue = 0;
};

#endif // SERIALREADER_H


