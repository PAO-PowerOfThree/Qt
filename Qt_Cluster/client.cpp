#include "client.hpp"
#include <iostream>
#include <vector>
#include <set>

VSomeIPClient::VSomeIPClient(QObject *parent) : QObject(parent) {
    app = vsomeip::runtime::get()->create_application("client");
    // Thread-safe queued connection for sending messages from GUI/QML
    connect(this, &VSomeIPClient::sendMessage, this, &VSomeIPClient::processMessage, Qt::QueuedConnection);
}

VSomeIPClient::~VSomeIPClient() {
    stop();
}

void VSomeIPClient::startClient() {
    if (running) return;
    vsomeipThread = std::thread([this]() { this->runClient(); });
}

void VSomeIPClient::runClient() {
    // --- STEP 1: REGISTER HANDLERS BEFORE INIT ---
    app->register_availability_handler(SERVICE_ID, INSTANCE_ID,
        [this](vsomeip::service_t, vsomeip::instance_t, bool is_available) {
            std::cout << "[Yocto Client] Server is "
                      << (is_available ? "available" : "unavailable") << std::endl;
            emit serverAvailabilityChanged(is_available);

            if (is_available) {
                // Subscribe to event group when service is available
                app->subscribe(SERVICE_ID, INSTANCE_ID, EVENT_GROUP_ID);
                std::cout << "[Yocto Client] Subscribed to event group 0x"
                          << std::hex << EVENT_GROUP_ID << std::dec << std::endl;
            } else {
                app->unsubscribe(SERVICE_ID, INSTANCE_ID, EVENT_GROUP_ID);
                std::cout << "[Yocto Client] Unsubscribed from event group 0x"
                          << std::hex << EVENT_GROUP_ID << std::dec << std::endl;
            }
        });

    app->register_message_handler(SERVICE_ID, INSTANCE_ID, METHOD_ID,
        [this](const std::shared_ptr<vsomeip::message> &response) {
            std::string received(reinterpret_cast<const char*>(response->get_payload()->get_data()),
                                 response->get_payload()->get_length());
            std::cout << "[Yocto Client] Received method response: " << received << std::endl;
            emit messageReceived(QString::fromStdString(received));
        });

    app->register_message_handler(SERVICE_ID, INSTANCE_ID, EVENT_ID_SPEED,
        [this](const std::shared_ptr<vsomeip::message> &msg) {
            std::string received(reinterpret_cast<const char*>(msg->get_payload()->get_data()),
                                 msg->get_payload()->get_length());
            std::cout << "[Yocto Client] Received speed update: " << received << std::endl;
            emit messageReceived(QString::fromStdString(received));
        });

    // --- STEP 2: INIT APPLICATION ---
    if (!app->init()) {
        std::cerr << "[Yocto Client] Init failed!" << std::endl;
        return;
    }

    // --- STEP 3: REGISTER INTEREST IN THE EVENT ---
    {
        std::set<vsomeip::eventgroup_t> groups;
        groups.insert(EVENT_GROUP_ID);

        // Register event with runtime so it knows about it
        app->request_event(SERVICE_ID, INSTANCE_ID, EVENT_ID_SPEED, groups,
                           vsomeip::event_type_e::ET_EVENT,
                           vsomeip::reliability_type_e::RT_UNRELIABLE);

        std::cout << "[Yocto Client] Requested event 0x" << std::hex << EVENT_ID_SPEED
                  << " in group 0x" << EVENT_GROUP_ID << std::dec << std::endl;
    }

    // --- STEP 4: REQUEST THE SERVICE ---
    app->request_service(SERVICE_ID, INSTANCE_ID);

    running = true;
    app->start();
}

void VSomeIPClient::sendMessage(const QString &message) {
    QMetaObject::invokeMethod(this, "processMessage", Qt::QueuedConnection, Q_ARG(QString, message));
}

void VSomeIPClient::processMessage(const QString &message) {
    if (!running) {
        std::cerr << "[Yocto Client] Cannot send message, client is not running." << std::endl;
        return;
    }

    auto request = vsomeip::runtime::get()->create_request();
    request->set_service(SERVICE_ID);
    request->set_instance(INSTANCE_ID);
    request->set_method(METHOD_ID);

    std::string msg_str = message.toStdString();
    std::vector<vsomeip::byte_t> payload_data(msg_str.begin(), msg_str.end());
    auto payload = vsomeip::runtime::get()->create_payload();
    payload->set_data(payload_data);
    request->set_payload(payload);

    app->send(request);
    std::cout << "[Yocto Client] Sent message: " << msg_str << std::endl;
}

void VSomeIPClient::stop() {
    if (running) {
        try {
            app->unsubscribe(SERVICE_ID, INSTANCE_ID, EVENT_GROUP_ID);
            app->release_event(SERVICE_ID, INSTANCE_ID, EVENT_ID_SPEED);
            app->release_service(SERVICE_ID, INSTANCE_ID);
        } catch (const std::exception &e) {
            std::cerr << "[Yocto Client] Exception during stop: " << e.what() << std::endl;
        }

        app->stop();
        running = false;
    }

    if (vsomeipThread.joinable()) {
        vsomeipThread.join();
    }
}
