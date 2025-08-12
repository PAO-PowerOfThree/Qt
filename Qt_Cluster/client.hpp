#ifndef CLIENT_HPP
#define CLIENT_HPP

#include <QObject>
#include <vsomeip/vsomeip.hpp>
#include <memory>
#include <thread>
#include <atomic>

// These IDs MUST match the AOSP server configuration
constexpr vsomeip::service_t     SERVICE_ID      = 0x4111;
constexpr vsomeip::instance_t    INSTANCE_ID     = 0x3111;
constexpr vsomeip::method_t      METHOD_ID       = 0x6000;
constexpr vsomeip::event_t       EVENT_ID_SPEED  = 0x7001;
constexpr vsomeip::eventgroup_t  EVENT_GROUP_ID  = 0x01;

class VSomeIPClient : public QObject {
    Q_OBJECT
public:
    explicit VSomeIPClient(QObject *parent = nullptr);
    ~VSomeIPClient();

    // Method to be called from QML/C++ to start the client logic
    Q_INVOKABLE void startClient();

    // Method to send a request to the server
    Q_INVOKABLE void sendMessage(const QString &message);

signals:
    // Signal emitted when any message (response or event) is received from the server
    void messageReceived(const QString &message);

    // Signal emitted when the server's availability status changes
    void serverAvailabilityChanged(bool isAvailable);

private:
    // The entry point for the dedicated vsomeip thread
    void runClient();

    // Stops the client and joins the thread
    void stop();

    // Internal slot to safely send messages from the Qt event loop
    void processMessage(const QString &message);

    std::shared_ptr<vsomeip::application> app;
    std::thread vsomeipThread;
    std::atomic<bool> running{false};
};

#endif // CLIENT_HPP
