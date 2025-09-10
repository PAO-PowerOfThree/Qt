# Qt6 Embedded IVI — VSomeIP, CAN Bus & ESP32 Fingerprint (DETAILED)

## One-line summary
A complete, production-minded explanation of a Qt6-based In-Vehicle Infotainment (IVI) backend integrating **VSomeIP** (client + server), **SocketCAN** (via `QCanBus`), and **UART** communication to an **ESP32 fingerprint** module. This README explains the architecture, file responsibilities, protocols, data formats, threading, deployment, testing, debugging, security, and extension paths in depth.

---
## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Repository & File Map (detailed)](#repository--file-map-detailed)
3. [Component Deep Dives](#component-deep-dives)
   - [BusReader (CAN)](#busreader-can)
   - [SerialManager (UART)](#serialmanager-uart)
   - [VSomeIP client/server (vsomeip integration)](#vsomeip-clientserver)
4. [Data Formats and Protocols](#data-formats-and-protocols)
5. [QML / UI Integration Examples](#qml--ui-integration-examples)
6. [Build, Packaging & Deployment](#build-packaging--deployment)
7. [System & Device Setup (CAN, Serial, Network)](#system--device-setup-can-serial-network)
8. [Testing, Simulation & Debugging](#testing-simulation--debugging)
9. [Threading, Concurrency & Lifecycle](#threading-concurrency--lifecycle)
10. [Security Considerations](#security-considerations)
11. [Troubleshooting FAQ](#troubleshooting-faq)
12. [Extending the Project](#extending-the-project)
13. [Appendices (snippets)](#appendices-snippets)
14. [License & Contributors](#license--contributors)

---
# Architecture Overview

The system is designed for an embedded Linux (e.g., Yocto on Raspberry Pi) IVI application. The backend components are C++/Qt6 classes that provide data and services to a QML interface. The major subsystems are:

- **SocketCAN interface** (`BusReader`) to read vehicle bus frames and expose values to QML via `Q_PROPERTY`.
- **Serial UART** (`SerialManager`) to communicate with an ESP32 that handles fingerprint sensor hardware and prints human-readable lines to UART.
- **VSomeIP (vsomeip)** integration (`VSomeIPClient`) to communicate with peer IVI systems (AOSP) using SOME/IP event semantics (request/response, events, event-groups).
- **QML frontend** that consumes `BusReader`, `SerialManager`, and `VSomeIPClient` signals/properties for the IVI UI and control flows.

A simplified ASCII diagram:

```
  +-------------+     SocketCAN    +-------------+
  |  CAN bus    | <--------------> |  BusReader  |
  | (can0 / ECU)|                   +------+------+
  +-------------+                          |
                                           v
                                    +------+-------+
                                    |  Qt6 Backend |
                                    |  - BusReader |
                                    |  - SerialMgr |
                                    |  - VSomeIP    |
                                    +------+-------+
                                           |
                 UART (/dev/ttyS0)         v
  +-------------+ <----------------> +----+-------+
  |  ESP32 w/   |                   |  QML UI     |
  |  fingerprint|                   | (IVI display)|
  +-------------+                   +-------------+

  VSomeIP (SOME/IP) runs in-process as a client+server offering/consuming events
  to/from the AOSP peer on the network (multicast discovery + unicast traffic).
```

---
# Repository & File Map (detailed)

Below is a recommended map (validate against your repo). For files you already shared, I list them and suggest a few common supportive files.

```
/project-root
├─ src/
│  ├─ busreader.h/.cpp        # CAN reader (QCanBus)
│  ├─ serialmanager.h/.cpp    # UART / ESP32 gateway, password + events
│  ├─ client.hpp/.cpp         # VSomeIP client/server wrapper
│  ├─ main.cpp                # Qt application bootstrap + singletons
│  ├─ applicationcontroller.* # glue between C++ objects and QML context
│  └─ qml/                    # QML frontend (main.qml and controls)
│     ├─ Main.qml
│     ├─ Speedometer.qml
│     ├─ BatteryGauge.qml
│     ├─ FuelGauge.qml
│     └─ FingerprintDialog.qml
├─ cmake/ or build/            # CMake helpers or toolchain files for Yocto
├─ CMakeLists.txt
├─ resources/                  # icons, fonts, translations
├─ vsomeip.json                # vsomeip runtime config
├─ packaging/                  # systemd unit, service files, udev rules
└─ docs/
   └─ README.md (this)
```

Each file's responsibility (short form - deeper explanations in next section):

- `busreader.*` — capture SocketCAN frames, parse values, `Q_PROPERTY` exposure.
- `serialmanager.*` — serial parsing, command/response protocol, map text to `APPROVED`/`REFUSED`, password storage.
- `client.*` — vsomeip application lifecycle, thread, offer & request services, create/send payloads as events or requests.
- `vsomeip.json` — network configuration: discovery, multicast groups, unicast, logging.
- `CMakeLists.txt` — build rules, find_package(Qt6 ...), link vsomeip libs, install targets.

---
# Component Deep Dives

## BusReader (CAN)

**Goal**: Safe, robust reading of frames and exposing vehicle values to QML.

Key responsibilities (as in your code):
- Create device with `QCanBus::instance()->createDevice("socketcan", "can0", &err)`
- Connect to it and subscribe to `framesReceived` signal.
- In `readCanData()` loop: call `framesAvailable()` then `readFrame()` repeatedly.
- Parse frames by `frameId()` and `frame.payload()` size and content.

**Frame parsing decisions (detailed)**:
- You treat payload bytes as big-endian 16-bit values for ADC and PWM:
  ```cpp
  int adc = (frame.payload()[0] << 8) | frame.payload()[1];
  ```
  That expression assumes the sender places the MSB in byte0 and LSB in byte1 (network-style big-endian). If your ECU uses little-endian, you'd reverse the combination. Confirm on the sender side.

- You clamp ADC values to `0..4095` (12-bit ADC). The `qBound(0, level, 4095)` assures the value remains in this range even if noisy/wrong frames arrive.

**Why clamping and validation matter**:
- CAN frames can be corrupted by bus noise or misconfigured sender. Validation avoids feeding nonsensical values into UI (which could break visualizations) and avoids buffer overflows if you later use the ADC to index an array.

**Scaling ADC to UI-friendly units**:
- ADC (0..4095) → percentage (0..100):
  ```cpp
  double percent = 100.0 * double(adc) / 4095.0;
  ```
- ADC → voltage (assuming Vref = 3.3V):
  ```cpp
  double voltage = 3.3 * double(adc) / 4095.0;
  ```
Consider adding conversion helpers on `BusReader` if your UI needs percent or volts directly (expose as `Q_PROPERTY double batteryPercent() const` etc.).

**Performance**:
- `framesReceived` can fire frequently for heavy buses. Avoid expensive operations inside parsing loop. Buffer and emit coarse-grained signals (e.g., emit `batteryLevelChanged()` only when the displayed value bucket changes). You already do this via `if (m_batteryLevel != level)` which is good.

**Example extended parsing (bit fields)**:
- Suppose a 2-byte payload stores flags in upper nibble and ADC in lower 12 bits:
  ```cpp
  quint16 raw = (payload[0] << 8) | payload[1];
  bool flag = raw & 0x8000;
  int adc12 = raw & 0x0FFF;
  ```

---
## SerialManager (UART) — Deep explanation

**Goal**: Robustly communicate with the ESP32 fingerprint module over UART and map textual responses to events consumed by the local UI and remote AOSP via VSomeIP.**Key responsibilities**:
- Configure `QSerialPort` parameters (port, baud, parity, data bits, stop bits, flow control).
- Open the device and handle `readyRead()` notifications.
- Buffer incoming bytes and split by CR/LF boundaries (you used `\r\n` splitting).
- Map textual lines to semantic events like `"APPROVED"/"REFUSED"` and emit signals for UI and VSomeIP client.

**Why you buffer and split lines**:
- Serial delivers arbitrary-sized chunks, not neat lines. A multi-line message may arrive in fragments. The buffer + split approach concatenates until you detect a full line (`\r\n`) — robust and standard.

**Command protocol**:
- `sendEnroll()` and `sendClear()` call `emit requestPassword("ENROLL")` which opens a password prompt in your UI; after success you likely send an enrollment command over UART. For the low-level send, you use:
  ```cpp
  m_serial->write((cmd + "\n").toUtf8());
  ```
  Make sure the ESP32 expects `\n` or `\r\n`. Match the newline exactly.

**Mapping to `APPROVED`/`REFUSED`**:
- The AOSP side expects exact uppercase strings; normalizing to uppercase removes ambiguity: `ACCESS GRANTED` → `APPROVED`. Also strip whitespace.

**Password handling**:
- You calculate SHA256 and persist to `~/.fingerprint_app/password.hash`. Important points:
  - Use `QDir().mkpath()` to create the folder.
  - Set the saved file mode to `0600` to protect it from other users (see system/install steps below).
  - Consider hardware-backed keystore or TPM on production devices.

**Serial error modes**:
- If the port fails to open, your code continues in test mode — good for UI development. When targeting the RPi, configure udev rules and permissions so the runtime user can own `/dev/ttyS0` or use a systemd service that adjusts capabilities.


---
## VSomeIP client/server (vsomeip integration)

**Goal**: Provide SOME/IP events for remote AOSP systems and consume AOSP events locally. The `VSomeIPClient` does both: subscribes to a remote service and also *offers* its own fingerprint event.

**Important pieces**:
- **Application lifecycle**: You create a `vsomeip::application` and run it in a dedicated `std::thread`. This avoids blocking the Qt event loop and also isolates the vsomeip runtime.
- **Register availability handler**: When the remote server becomes available, subscribe to event groups. When it becomes unavailable, unsubscribe.
- **Register message handlers**: For method responses and events, provide callbacks that `emit messageReceived(...)` for QML.
- **Offer fingerprint service**: `app->offer_service(FINGER_SERVICE_ID, FINGER_INSTANCE_ID)` and `app->offer_event(...)` so AOSP clients can subscribe to your fingerprint event.
- **Send fingerprint status**: `notify(FINGER_SERVICE_ID, FINGER_INSTANCE_ID, EVENT_ID_FINGER, payload)` with payload containing ASCII `"APPROVED"` or `"REFUSED"`. Use event semantics (notify) rather than method call for asynchronous broadcast.

**Queued connections**:
- Because vsomeip runs in its own thread, you use `QMetaObject::invokeMethod` or `emit` with `Qt::QueuedConnection` to safely cross threads.

**Config (`vsomeip.json`)**:
- `unicast`: binds a specific local address
- `service` objects: define services, events, methods and group membership
- `service-discovery`: controls multicast discovery; `multicast` and `port` must match peers
- `logging.level`: set to `debug` while developing

Ensure any multicast IPs and ports are allowed by your network / docker / IP stack.

**Reliability choices**:
- SOME/IP supports reliable/unreliable event types. Choose `RT_UNRELIABLE` for frequently-updated, non-critical events (e.g., speed) to save bandwidth. Use reliable for critical state or commands.

---
# Data Formats and Protocols

## CAN messages (IDs you used)
- `0x101` (Left indicator): 1-byte payload. Value: `0x00` = off, non-zero = on.
- `0x102` (Battery): 4-byte payload.
  - Byte0..1: 16-bit ADC (big-endian) for battery voltage (0..4095)
  - Byte2..3: 16-bit PWM (big-endian) for display brightness or PWM setpoint (0..1000)
- `0x103` (Right indicator): 1-byte payload (same mapping as 0x101).
- `0x104` (Fuel): 4-byte payload (adc + pwm).

**Example raw frame encoding** (cansend style):
```
cansend can0 102#0FFF03E8
# 0FFF = 4095 (0x0FFF) -> battery ADC, 03E8 = 1000 -> PWM
```
If you use `cansend` with hex you must ensure the payload length matches intended bytes; many tools accept both hex stream and formatted bytes.

**Note on Endianness**: You assumed bytes are big-endian when combining `(b0 << 8) | b1`. Confirm with sender; otherwise swap order.

## UART messages (ESP32 → Yocto)

Typical lines the ESP32 might send (examples you parse):
- `ACCESS GRANTED` → map to `APPROVED`
- `Fingerprint not recognized` → map to `REFUSED`
- `FINGERPRINT ENROLLED SUCCESSFULLY` → UI event `enrolledSuccess()`

**Robust parsing recommendations**:
- Trim whitespace, apply `toUpper()` for canonicalization when matching tokens.
- If you add binary-capable sensor payloads in future, consider adding a short text header describing length and a checksum, e.g.: `MSG:OK;TYPE:FINGER;LEN:4;DATA:0101;CRC:XXXX`

## VSomeIP payloads

You used simple ASCII payloads for events and messages. For production, define a strict message schema — e.g., JSON or CBOR — so payload length and typing are explicit. Example JSON for fingerprint event:
```json
{ "type": "fingerprint", "status": "APPROVED", "ts": 169..." }
```

JSON is verbose but human-readable; CBOR or protobuf is more compact and binary-safe. SOME/IP payload length limits and encoding details should be verified for your middleware version.

---
# QML / UI Integration Examples

**How to expose C++ singletons to QML**:
In `main.cpp` (example):
```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "busreader.h"
#include "serialmanager.h"
#include "client.hpp"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    BusReader bus;
    SerialManager serial;
    VSomeIPClient vsomeip;
    serial.setVSomeIPClient(&vsomeip);

    engine.rootContext()->setContextProperty("busReader", &bus);
    engine.rootContext()->setContextProperty("serialManager", &serial);
    engine.rootContext()->setContextProperty("vSomeIP", &vsomeip);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    return app.exec();
}
```

**QML example binding to battery and left indicator**:
```qml
// BatteryGauge.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: 200; height: 100
    Column {
        ProgressBar {
            id: battBar
            value: busReader.batteryLevel / 4095.0 // 0..1
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text { text: Math.round((busReader.batteryLevel/4095.0) * 100) + "%" }
    }
}
```

**Reacting to fingerprint events**:
```qml
// Main.qml
Connections {
    target: serialManager
    onAccessGranted: {
        // Play unlock animation, notify user
    }
    onAccessRefused: {
        // Show error
    }
}
```

**Invoking enrollment**:
```qml
Button {
    text: "Enroll Finger"
    onClicked: serialManager.sendEnroll()
}
```

Because `VSomeIPClient` runs in a separate thread, make sure any method you call from QML is `Q_INVOKABLE` and thread-safe. You already set `sendMessage` and `sendFingerprintStatus` as Q_INVOKABLEs (or use `QMetaObject::invokeMethod` in C++ to enqueue).

---
# Build, Packaging & Deployment

## Dependencies
- **Qt 6.8+** (core, quick, serialport, network)
- **libvsomeip / vsomeip2** (SOME/IP runtime)
- **can-utils** (for debugging: `cansend`, `candump`, `cansniffer`)
- **g++ / clang** and CMake.
- Kernel with SocketCAN support (common on RPi distributions).

## Example CMakeLists fragment
```cmake
cmake_minimum_required(VERSION 3.16)
project(ivi_app LANGUAGES CXX)

find_package(Qt6 COMPONENTS Core Quick SerialPort REQUIRED)
find_package(vsomeip REQUIRED) # Replace with exact find module you use

add_executable(ivi_app
    src/main.cpp
    src/busreader.cpp
    src/serialmanager.cpp
    src/client.cpp
)

target_include_directories(ivi_app PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(ivi_app PRIVATE Qt6::Core Qt6::Quick Qt6::SerialPort vsomeip::vsomeip)
set_target_properties(ivi_app PROPERTIES CXX_STANDARD 20)
```

## Packaging for Yocto/Raspberry Pi
- Create a recipe that builds Qt5/6 application and installs binary to `/usr/bin/`.
- Add `SYSTEMD_SERVICE_${PN}` to enable running via systemd at boot.
- Ensure vsomeip json is installed to `/etc/vsomeip/vsomeip.json` and configure service discovery as needed.

## Systemd service example (`packaging/ivi_app.service`)
```ini
[Unit]
Description=IVI Qt6 Application
After=network.target

[Service]
User=iviuser
Group=iviuser
Environment=QT_QPA_PLATFORM=eglfs
ExecStart=/usr/bin/ivi_app
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical.target
```

**Note**: `QT_QPA_PLATFORM=eglfs` for full-screen KMS/EGL on embedded displays. Use `XCB` on desktop for testing.

---
# System & Device Setup (CAN, Serial, Network)

## SocketCAN (bring up can0)
```bash
sudo ip link set can0 down
sudo ip link set can0 up type can bitrate 500000
# Verify
ip -details link show can0
```
If `can0` doesn't exist, ensure your hardware or virtual CAN (vcan) is created. For testing, you can do:
```bash
sudo modprobe vcan
sudo ip link add dev vcan0 type vcan
sudo ip link set up vcan0
```
Then run your app against `vcan0` by changing `createDevice("socketcan","vcan0")`.

## Serial (udev rule)
Create `/etc/udev/rules.d/99-esp32.rules`:
```
KERNEL=="ttyUSB[0-9]*", ATTRS{idVendor}=="XXXX", ATTRS{idProduct}=="YYYY", SYMLINK+="esp32", MODE="0660", GROUP="dialout"
```
Restart udev with `sudo udevadm control --reload-rules && sudo udevadm trigger` and then set your app to open `/dev/esp32` or `/dev/ttyS0` after symlink.

## Network & vsomeip
- Ensure multicast is allowed and routers/switches don't block the discovery multicast address you configured (your `vsomeip.json` example uses 224.244.224.245 for discovery).

- For development on a single host, set `unicast` to the host's IP and ensure the `applications`/`services` IDs match between peers.

---
# Testing, Simulation & Debugging

## CAN test utilities (can-utils)
- `cansend` to send frames
  ```bash
  cansend can0 101#01      # left indicator on (1 byte)
  cansend can0 103#00      # right indicator off
  cansend can0 102#0FFF03E8  # battery ADC=4095, PWM=1000
  ```
- `candump can0` to view bus traffic in real time.

## Serial tests
- Local echo testing (if no ESP32 available):
  ```bash
  socat -d -d pty,raw,echo=0 pty,raw,echo=0
  # Connect one pty as /dev/ttyV0 and the other as /dev/ttyV1; write to one and the other receives.
  echo "ACCESS GRANTED" > /dev/ttyV0
  ```

- Or test the SerialManager by writing test lines with `echo` or `printf` to the serial device file you use.

## VsSomeIP logs & troubleshooting
- Increase `logging.level` in `vsomeip.json` to `debug` and check the output of the application for discovery and subscription life-cycle logs.
- If discovery fails, verify multicast address and port, and check `ss -lun` / `ss -un` to see if sockets are bound.

## Timeline for a fingerprint acceptance test
1. ESP32: `ACCESS GRANTED` arrives on `/dev/ttyS0`.
2. SerialManager reads line -> normalizes to `APPROVED` -> `m_vsomeipClient->sendFingerprintStatus("APPROVED")`.
3. VSomeIP `notify()` sends an event to the AOSP subscriber.
4. AOSP receives event and acts (e.g., unlock door).

---
# Threading, Concurrency & Lifecycle

**VSomeIP thread & Qt thread interaction**:
- You run vsomeip in `vsomeipThread`. All operations creating/using `app` must be performed on that thread or follow the library's threading model.
- C++->QML or QML->C++ calls crossing threads should use queued connections or `QMetaObject::invokeMethod` with `Qt::QueuedConnection` to avoid race conditions.
- Proper shutdown: `stop()` must ensure unsubscribes/remove offers and `app->stop()` then `vsomeipThread.join()` to avoid accessing freed memory.

**Destructor order**:
- Ensure `SerialManager` stops any ongoing IO and the `VSomeIPClient` stops before deleting the runtime objects. If singletons are used, their destroy order at process exit matters.

---
# Security Considerations (detailed)

- **Password storage**: You store SHA256 hash in `~/.fingerprint_app/password.hash`. Improve on this by:
  - Setting file mode `0600`.
  - Storing a salted hash (store salt per user or within file and use `PBKDF2` or `Argon2` rather than raw single-shot SHA256 to mitigate brute-force).
  - Use hardware-backed key storage on secured boards.
- **UART authenticity**: Plain-text UART can be spoofed; add framing with a signature/HMAC if the fingerprint acceptance is security-critical.
- **Network security**: SOME/IP by default is not encrypted. Use network-level protections (VPN, dedicated VLAN, switched network, or secure SOME/IP features if available in your stack).
- **Access control**: Restrict which devices/users can read/write to the UART and to the CAN interface via udev and systemd. Use `CapabilityBoundingSet` or file permissions to reduce risk.
- **Input validation**: Validate every incoming external string and frame. Avoid trusting raw message lengths; always check payload size before reading indexes.

---
# Troubleshooting FAQ (common causes & fixes)

- **QCanBus::createDevice returned null / connectDevice failed**:
  - Ensure `socketcan` plugin is available in Qt build (`qtconnectivity` module) and the kernel supports SocketCAN.
  - `ip link` shows `can0` and it's `up` (bitrate set).
  - Run as root or grant capabilities; check dmesg if driver missing.
- **Serial port cannot open**:
  - Wrong device path (`/dev/ttyUSB0` vs `/dev/ttyS0`) or permission denied. Add the user to `dialout` or udev rules.
- **VSomeIP discovery or subscriptions not working**:
  - Check multicast address and port in both peers' `vsomeip.json`. Ensure your host firewall allows multicast.
- **Events arrive but QML doesn't update**:
  - Check that you emit `XXXChanged()` signals and the `Q_PROPERTY` notifications are defined. QML bindings depend on these notifications.
- **Memory leak on shutdown**:
  - Verify thread join and `app->stop()` calls run before objects are destroyed. Use sanitizers during development.

---
# Extending the Project (ideas & guidance)

- **Add ACK / heartbeat mechanism** between Yocto and AOSP to confirm event reception.
- **Switch payloads to CBOR / protobuf** for strongly-typed, compact messages.
- **Add firmware update** mechanism for ESP32 via a secure channel guarded by signed images.
- **Add unit tests** for parsing code (simulate frames and assert property changes).
- **Add integration tests** in a CI pipeline using vcan and pseudo-serial devices via `socat`.
- **Add encryption**: wrap SOME/IP traffic in IPsec or configurable TLS tunnels.

---
# Appendices (snippets)

## Convert ADC to percent and voltage (C++ helper):
```cpp
double adcToPercent(int adc) {
    return (100.0 * static_cast<double>(qBound(0, adc, 4095))) / 4095.0;
}
double adcToVoltage(int adc, double vref=3.3) {
    return (vref * static_cast<double>(qBound(0, adc, 4095))) / 4095.0;
}
```

## Example `udev` rule (package/installation):
```
# /etc/udev/rules.d/99-esp32.rules
SUBSYSTEM=="tty", KERNEL=="ttyUSB[0-9]*", MODE="0660", GROUP="dialout", SYMLINK+="esp32"
```

## Systemd unit (debug mode):
```ini
[Service]
ExecStart=/usr/bin/ivi_app --verbose
StandardOutput=file:/var/log/ivi_app.log
StandardError=file:/var/log/ivi_app.err
```

---
# License & Contributors

Suggested license: **MIT** (permissive) or **Apache 2.0** if you want patent/grant clarity. Add a `CONTRIBUTING.md` if you expect collaborators.

---
