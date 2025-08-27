// client.hpp - Unchanged from provided code
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

// New IDs for fingerprint service (Yocto as server, AOSP as client)
constexpr vsomeip::service_t     FINGER_SERVICE_ID      = 0x4222;
constexpr vsomeip::instance_t    FINGER_INSTANCE_ID     = 0x3222;
constexpr vsomeip::event_t       EVENT_ID_FINGER        = 0x7002;
constexpr vsomeip::eventgroup_t  FINGER_EVENT_GROUP_ID  = 0x02;

class VSomeIPClient : public QObject {
    Q_OBJECT
public:
    explicit VSomeIPClient(QObject *parent = nullptr);
    ~VSomeIPClient();

    // Method to be called from QML/C++ to start the client logic
    Q_INVOKABLE void startClient();

    // Method to send a request to the server
    Q_INVOKABLE void sendMessage(const QString &message);

    // New: Method to send fingerprint status to AOSP ("APPROVED" or "REFUSED")
    Q_INVOKABLE void sendFingerprintStatus(const QString &status);

signals:
    // Signal emitted when any message (response or event) is received from the server
    void messageReceived(const QString &message);

    // Signal emitted when the server's availability status changes
    void serverAvailabilityChanged(bool isAvailable);

    // New: Internal signal for queued fingerprint processing
    void sendFingerprint(const QString &status);

private:
    // The entry point for the dedicated vsomeip thread
    void runClient();

    // Stops the client and joins the thread
    void stop();

    // Internal slot to safely send messages from the Qt event loop
    void processMessage(const QString &message);

    // New: Internal slot to safely send fingerprint status
    void processFingerprint(const QString &status);

    std::shared_ptr<vsomeip::application> app;
    std::thread vsomeipThread;
    std::atomic<bool> running{false};
};

#endif // CLIENT_HPP