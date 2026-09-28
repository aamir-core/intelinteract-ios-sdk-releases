# intelinteract Widget SDK — iOS

A plug-and-play customer support call/chat widget for iOS. Provides a floating button that opens a native modal with agent card, phone/OTP verification (or SSO via `APP_CONNECT`), and live voice/video calling via LiveKit.

---

## Requirements

| Requirement | Minimum  |
|-------------|----------|
| iOS         | 15+      |
| Xcode       | 15+      |
| Swift       | 5.9+     |

---

<details>
<summary><strong>Native iOS Integration</strong></summary>

<br>

### 1. Add the SDK package in Xcode

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the package URL:
   ```
   https://github.com/aamir-core/intelinteract-ios-sdk-releases
   ```
3. Select **Up to Next Major Version** from `1.0.0`
4. Click **Add Package**
5. Add **IntelinteractWidget** to your app target

---

### 2. Info.plist Permissions

Add these keys to your app's `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>intelinteract needs microphone access for voice calls.</string>
<key>NSCameraUsageDescription</key>
<string>intelinteract needs camera access for video calls.</string>
```

---

### 3. Usage

#### OTP auth (default)

```swift
import IntelinteractWidgetCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard let window = UIApplication.shared.windows.first else { return true }

        IntelinteractWidget.shared.initialize(
            tenantId: "your-tenant-id",
            widgetId: "your-widget-id",
            // baseUrl: "https://your-base-url.com",  // optional
            // fabX: 20,                               // optional: points from left edge
            // fabY: 100,                              // optional: points from top edge
            in: window
        ) { event in
            // event.action     → "CALL_INITIATED" | "CALL_RINGING" | "CALL_PICKED_UP" | "CALL_ENDED"
            // event.agentName  → display name of the agent
            // event.userId     → resolved Contact ID (available after auth)
            // event.token      → session token (available after auth)
            print("IntelinteractEvent: \(event.action) — \(event.agentName)")
        }

        IntelinteractWidget.shared.show()
        return true
    }
}
```

#### SSO auth (`APP_CONNECT`)

> **Prerequisite:** the widget must be configured with `providerType: "APP_CONNECT"` on the intelinteract server side. Contact the intelinteract team to enable this for your widget.

When `APP_CONNECT` is enabled, the OTP / phone-number screen is skipped entirely. Call `setToken()` with your backend-issued JWT as soon as it is available. The SDK buffers the token internally — it is safe to call `setToken()` before `initialize()` completes.

```swift
IntelinteractWidget.shared.initialize(tenantId: "your-tenant-id", widgetId: "your-widget-id", fabX: 20, fabY: 100, in: window) { event in
    print("IntelinteractEvent: \(event.action)")
}

// Safe to call right away — token is buffered until config fetch completes
IntelinteractWidget.shared.setToken("jwt-from-your-backend")
IntelinteractWidget.shared.show()
```

The widget exchanges the JWT for a intelinteract session token automatically and loads the user's details.

---

### API Reference

| Method | Description |
|--------|-------------|
| `IntelinteractWidget.shared.initialize(tenantId:widgetId:baseUrl:fabX:fabY:in:onEvent:)` | Initialise the SDK. Fetches widget config from the server. `baseUrl` defaults to `https://widget.nexivo.dev.cognitry.io`. `fabX`/`fabY` set the initial FAB position in points from the top-left corner; defaults to bottom-right. |
| `IntelinteractWidget.shared.setToken(_:)` | Attach a JWT for `APP_CONNECT` SSO auth. Call after `initialize()` and after your user logs in. |
| `IntelinteractWidget.shared.show()` | Make the floating button visible. |
| `IntelinteractWidget.shared.hide()` | Hide the floating button. |
| `IntelinteractWidget.shared.destroy()` | Remove the widget and release resources. |

---

### Event Reference

| Field        | Type      | Description                                      |
|--------------|-----------|--------------------------------------------------|
| `action`     | `String`  | One of `CALL_INITIATED`, `CALL_RINGING`, `CALL_PICKED_UP`, `CALL_ENDED` |
| `agentName`  | `String`  | Display name of the agent                        |
| `userId`     | `String?` | Resolved Contact ID in the intelinteract system (set after auth) |
| `token`      | `String?` | Session token (set after auth)                   |
| `timestamp`  | `Date`    | Event timestamp                                  |

---

## Credentials

Contact the intelinteract team to obtain your `tenantId` and `widgetId`.

</details>

---

<details>
<summary><strong>React Native Integration</strong></summary>

<br>

### 1. Add the SDK package in Xcode

1. Open your React Native project's `.xcworkspace` in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter:
   ```
   https://github.com/aamir-core/intelinteract-ios-sdk-releases
   ```
4. Select **Up to Next Major Version** from `1.0.0`
5. Click **Add Package**
6. Add **IntelinteractWidget** to your app target

---

### 2. Info.plist Permissions

Add these keys to your app's `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>intelinteract needs microphone access for voice calls.</string>
<key>NSCameraUsageDescription</key>
<string>intelinteract needs camera access for video calls.</string>
```

---

### 3. Create `IntelinteractWidgetModule.m`

Create this file inside `ios/YourApp/`:

```objc
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_REMAP_MODULE(IntelinteractWidget, IntelinteractWidgetModule, RCTEventEmitter)

RCT_EXTERN_METHOD(initWidget:(NSString *)tenantId widgetId:(NSString *)widgetId baseUrl:(NSString *)baseUrl fabX:(double)fabX fabY:(double)fabY)
RCT_EXTERN_METHOD(setToken:(NSString *)token)
RCT_EXTERN_METHOD(show)
RCT_EXTERN_METHOD(hide)
RCT_EXTERN_METHOD(destroy)

@end
```

---

### 4. Create `IntelinteractWidgetModule.swift`

Create this file inside `ios/YourApp/`:

```swift
import UIKit
import React
import IntelinteractWidgetCore

@objc(IntelinteractWidgetModule)
final class IntelinteractWidgetModule: RCTEventEmitter {

    private var hasListeners = false

    override static func requiresMainQueueSetup() -> Bool { true }
    override func supportedEvents() -> [String]! { ["IntelinteractEvent"] }
    override func startObserving() { hasListeners = true }
    override func stopObserving()  { hasListeners = false }

    @objc(initWidget:widgetId:baseUrl:fabX:fabY:)
    func initWidget(_ tenantId: String, widgetId: String, baseUrl: String, fabX: Double, fabY: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = Self.keyWindow() else { return }
            IntelinteractWidget.shared.initialize(
                tenantId: tenantId,
                widgetId: widgetId,
                baseUrl:  baseUrl,
                fabX:     fabX >= 0 ? CGFloat(fabX) : nil,
                fabY:     fabY >= 0 ? CGFloat(fabY) : nil,
                in:       window
            ) { [weak self] event in
                guard let self, self.hasListeners else { return }
                self.sendEvent(withName: "IntelinteractEvent", body: [
                    "action":    event.action,
                    "agentName": event.agentName,
                    "userId":    event.userId as Any,
                    "token":     event.token  as Any,
                    "timestamp": event.timestamp.timeIntervalSince1970 * 1000
                ])
            }
        }
    }

    @objc func setToken(_ token: String) {
        DispatchQueue.main.async { IntelinteractWidget.shared.setToken(token) }
    }

    @objc func show()    { DispatchQueue.main.async { IntelinteractWidget.shared.show() } }
    @objc func hide()    { DispatchQueue.main.async { IntelinteractWidget.shared.hide() } }
    @objc func destroy() { DispatchQueue.main.async { IntelinteractWidget.shared.destroy() } }

    override func addListener(_ eventName: String) {}
    override func removeListeners(_ count: Double) {}

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
    }
}
```

---

### 5. Add files to Xcode

1. In Xcode, right-click your app folder in the Project Navigator → **Add Files to "YourApp"**
2. Select both `IntelinteractWidgetModule.m` and `IntelinteractWidgetModule.swift`, then click **Add**
3. When Xcode asks **"Would you like to configure an Objective-C bridging header?"** → click **Create Bridging Header**
   - This automatically creates `YourApp-Bridging-Header.h`

---

### 6. Update the Bridging Header

Open `YourApp-Bridging-Header.h` and add:

```objc
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
```

---

### 7. Create `IntelinteractWidget.js`

```js
import { NativeModules, NativeEventEmitter } from 'react-native';

const { IntelinteractWidget } = NativeModules;
const emitter = IntelinteractWidget ? new NativeEventEmitter(IntelinteractWidget) : null;
const noop = () => {};

export default {
    init(tenantId, widgetId, baseUrl = '', fabX = -1, fabY = -1) {
        if (!IntelinteractWidget) return;
        IntelinteractWidget.initWidget(tenantId, widgetId, baseUrl, fabX, fabY);
    },
    setToken(token) {
        if (!IntelinteractWidget) return;
        IntelinteractWidget.setToken(token);
    },
    show:        IntelinteractWidget ? () => IntelinteractWidget.show()    : noop,
    hide:        IntelinteractWidget ? () => IntelinteractWidget.hide()    : noop,
    destroy:     IntelinteractWidget ? () => IntelinteractWidget.destroy() : noop,
    addListener: emitter
        ? (cb) => emitter.addListener('IntelinteractEvent', cb)
        : () => ({ remove: noop }),
};
```

---

### 8. Usage

#### OTP auth (default)

```tsx
import React, { useEffect } from 'react';
import IntelinteractWidget from './IntelinteractWidget';

export default function App() {
    useEffect(() => {
        IntelinteractWidget.init(
            'your-tenant-id',
            'your-widget-id',
            'https://your-base-url.com', // optional — pass '' to use default
            // 20,                        // optional fabX: points from left edge
            // 100,                       // optional fabY: points from top edge
        );
        IntelinteractWidget.show();

        const subscription = IntelinteractWidget.addListener((event) => {
            // event.action     → "CALL_INITIATED" | "CALL_RINGING" | "CALL_PICKED_UP" | "CALL_ENDED"
            // event.agentName  → display name of the agent
            // event.userId     → resolved Contact ID (available after auth)
            // event.token      → session token (available after auth)
            // event.timestamp  → Unix timestamp in milliseconds
            console.log('IntelinteractEvent:', event);
        });

        return () => {
            subscription.remove();
            IntelinteractWidget.destroy();
        };
    }, []);

    return (/* your app UI */);
}
```

#### SSO auth (`APP_CONNECT`)

> **Prerequisite:** the widget must be configured with `providerType: "APP_CONNECT"` on the intelinteract server side.

```tsx
import React, { useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import IntelinteractWidget from './IntelinteractWidget';

export default function App() {
    useEffect(() => {
        IntelinteractWidget.init(
            'your-tenant-id',
            'your-widget-id',
            'https://your-base-url.com', // required
            20,   // fabX — optional: points from left edge
            100,  // fabY — optional: points from top edge
        );

        AsyncStorage.getItem('accessToken').then((token) => {
            if (token) IntelinteractWidget.setToken(token);
            IntelinteractWidget.show();
        });

        return () => IntelinteractWidget.destroy();
    }, []);

    return (/* your app UI */);
}
```

---

### API Reference

| Method | Description |
|--------|-------------|
| `IntelinteractWidget.init(tenantId, widgetId, baseUrl?, fabX?, fabY?)` | Initialise the SDK. `baseUrl` is optional. `fabX`/`fabY` set the initial FAB position in points from the top-left corner; defaults to bottom-right. |
| `IntelinteractWidget.setToken(token)` | Attach a JWT for `APP_CONNECT` SSO auth. |
| `IntelinteractWidget.show()` | Make the floating button visible. |
| `IntelinteractWidget.hide()` | Hide the floating button. |
| `IntelinteractWidget.destroy()` | Remove the widget and release resources. |

---

### Event Reference

| Field        | Type     | Description                                      |
|--------------|----------|--------------------------------------------------|
| `action`     | `string` | One of `CALL_INITIATED`, `CALL_RINGING`, `CALL_PICKED_UP`, `CALL_ENDED` |
| `agentName`  | `string` | Display name of the agent                        |
| `userId`     | `string` | Resolved Contact ID in the intelinteract system (set after auth) |
| `token`      | `string` | Session token (set after auth)                   |
| `timestamp`  | `number` | Unix timestamp in milliseconds                   |

---

## Credentials

Contact the intelinteract team to obtain your `tenantId` and `widgetId`.

</details>

---

<details>
<summary><strong>Flutter Integration</strong></summary>

<br>

### 1. Add the SDK package in Xcode

1. Open your Flutter project's `.xcworkspace` in Xcode (inside the `ios/` folder)
2. Go to **File → Add Package Dependencies**
3. Enter:
   ```
   https://github.com/aamir-core/intelinteract-ios-sdk-releases
   ```
4. Select **Up to Next Major Version** from `1.0.0`
5. Click **Add Package**
6. Add **IntelinteractWidget** to your app target

---

### 2. Info.plist Permissions

Add these keys to your app's `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>intelinteract needs microphone access for voice calls.</string>
<key>NSCameraUsageDescription</key>
<string>intelinteract needs camera access for video calls.</string>
```

---

### 3. Create `IntelinteractPlugin.swift`

Create this file inside `ios/Runner/`:

```swift
import Flutter
import UIKit
import IntelinteractWidgetCore

public class IntelinteractPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "intelinteract_widget", binaryMessenger: registrar.messenger())
        let eventChannel  = FlutterEventChannel(name: "intelinteract_widget/events", binaryMessenger: registrar.messenger())
        let instance = IntelinteractPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "init":
            let tenantId = args?["tenantId"] as? String ?? ""
            let widgetId = args?["widgetId"] as? String ?? ""
            let baseUrl  = args?["baseUrl"]  as? String ?? ""
            var fabX: CGFloat? = nil
            if let n = args?["fabX"] as? NSNumber { fabX = CGFloat(n.doubleValue) }
            var fabY: CGFloat? = nil
            if let n = args?["fabY"] as? NSNumber { fabY = CGFloat(n.doubleValue) }
            let onEvent: (IntelinteractEvent) -> Void = { [weak self] event in
                DispatchQueue.main.async {
                    self?.eventSink?([
                        "action":    event.action,
                        "agentName": event.agentName,
                        "userId":    event.userId as Any,
                        "token":     event.token  as Any,
                        "timestamp": event.timestamp.timeIntervalSince1970 * 1000
                    ])
                }
            }
            DispatchQueue.main.async {
                guard let window = IntelinteractPlugin.keyWindow() else { return }
                IntelinteractWidget.shared.initialize(
                    tenantId: tenantId,
                    widgetId: widgetId,
                    baseUrl:  baseUrl,
                    fabX:     fabX,
                    fabY:     fabY,
                    in:       window,
                    onEvent:  onEvent
                )
            }
            result(nil)
        case "setToken":
            let token = args?["token"] as? String ?? ""
            DispatchQueue.main.async { IntelinteractWidget.shared.setToken(token) }
            result(nil)
        case "show":
            DispatchQueue.main.async { IntelinteractWidget.shared.show() }
            result(nil)
        case "hide":
            DispatchQueue.main.async { IntelinteractWidget.shared.hide() }
            result(nil)
        case "destroy":
            DispatchQueue.main.async { IntelinteractWidget.shared.destroy() }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
    }
}
```

---

### 4. Add file to Xcode

1. In Xcode, right-click the **Runner** folder in the Project Navigator → **Add Files to "Runner"**
2. Select `IntelinteractPlugin.swift` and click **Add**

---

### 5. Register in `AppDelegate.swift`

```swift
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if let registrar = self.registrar(forPlugin: "IntelinteractPlugin") {
            IntelinteractPlugin.register(with: registrar)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

---

### 6. Dart Bridge

Create `lib/intelinteract_widget.dart` in your Flutter project:

```dart
import 'dart:async';
import 'package:flutter/services.dart';

class IntelinteractEvent {
  final String action;
  final String agentName;
  final String? userId;
  final String? token;
  final double timestamp;

  const IntelinteractEvent({
    required this.action,
    required this.agentName,
    this.userId,
    this.token,
    required this.timestamp,
  });

  factory IntelinteractEvent.fromMap(Map<Object?, Object?> map) => IntelinteractEvent(
        action:    map['action']    as String? ?? '',
        agentName: map['agentName'] as String? ?? '',
        userId:    map['userId']    as String?,
        token:     map['token']     as String?,
        timestamp: (map['timestamp'] as num?)?.toDouble() ?? 0,
      );
}

class IntelinteractWidget {
  IntelinteractWidget._();

  static const _method = MethodChannel('intelinteract_widget');
  static const _events = EventChannel('intelinteract_widget/events');

  static Stream<IntelinteractEvent>? _stream;

  static Future<void> init({
    required String tenantId,
    required String widgetId,
    String baseUrl = '',
    int? fabX,
    int? fabY,
  }) =>
      _method.invokeMethod('init', {
        'tenantId': tenantId,
        'widgetId': widgetId,
        'baseUrl':  baseUrl,
        if (fabX != null) 'fabX': fabX,
        if (fabY != null) 'fabY': fabY,
      });

  static Future<void> setToken(String token) =>
      _method.invokeMethod('setToken', {'token': token});

  static Future<void> show()    => _method.invokeMethod('show');
  static Future<void> hide()    => _method.invokeMethod('hide');
  static Future<void> destroy() => _method.invokeMethod('destroy');

  static Stream<IntelinteractEvent> get onEvent {
    _stream ??= _events
        .receiveBroadcastStream()
        .map((e) => IntelinteractEvent.fromMap(e as Map<Object?, Object?>));
    return _stream!;
  }
}
```

---

### 7. Usage

#### OTP auth (default)

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'intelinteract_widget.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<IntelinteractEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _initIntelinteract();
  }

  Future<void> _initIntelinteract() async {
    await IntelinteractWidget.init(
      tenantId: 'your-tenant-id',
      widgetId: 'your-widget-id',
      // baseUrl: 'https://your-base-url.com',  // optional
      // fabX: 20,                               // optional: points from left edge
      // fabY: 100,                              // optional: points from top edge
    );
    await IntelinteractWidget.show();

    _subscription = IntelinteractWidget.onEvent.listen((event) {
      // event.action     → "CALL_INITIATED" | "CALL_RINGING" | "CALL_PICKED_UP" | "CALL_ENDED"
      // event.agentName  → display name of the agent
      // event.userId     → resolved Contact ID (available after auth)
      // event.token      → session token (available after auth)
      // event.timestamp  → Unix timestamp in milliseconds
      debugPrint('IntelinteractEvent: ${event.action} | ${event.agentName}');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    IntelinteractWidget.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('My App')),
        body: const Center(child: Text('Hello!')),
      ),
    );
  }
}
```

#### SSO auth (`APP_CONNECT`)

> **Prerequisite:** the widget must be configured with `providerType: "APP_CONNECT"` on the intelinteract server side.

```dart
Future<void> _initIntelinteract() async {
  await IntelinteractWidget.init(
    tenantId: 'your-tenant-id',
    widgetId: 'your-widget-id',
    // baseUrl: 'https://your-base-url.com',  // optional
    fabX: 20,   // optional: points from left edge
    fabY: 100,  // optional: points from top edge
  );

  final token = await _getStoredToken(); // your own auth token
  if (token != null) await IntelinteractWidget.setToken(token);
  await IntelinteractWidget.show();
}
```

---

### API Reference

| Method | Description |
|--------|-------------|
| `IntelinteractWidget.init(tenantId: widgetId: baseUrl: fabX: fabY:)` | Initialise the SDK. `baseUrl` is optional. `fabX`/`fabY` set the initial FAB position in points from the top-left corner; defaults to bottom-right. |
| `IntelinteractWidget.setToken(token)` | Attach a JWT for `APP_CONNECT` SSO auth. |
| `IntelinteractWidget.show()` | Make the floating button visible. |
| `IntelinteractWidget.hide()` | Hide the floating button. |
| `IntelinteractWidget.destroy()` | Remove the widget and release resources. |

---

### Event Reference

| Field        | Type      | Description                                      |
|--------------|-----------|--------------------------------------------------|
| `action`     | `String`  | One of `CALL_INITIATED`, `CALL_RINGING`, `CALL_PICKED_UP`, `CALL_ENDED` |
| `agentName`  | `String`  | Display name of the agent                        |
| `userId`     | `String?` | Resolved Contact ID in the intelinteract system (set after auth) |
| `token`      | `String?` | Session token (set after auth)                   |
| `timestamp`  | `double`  | Unix timestamp in milliseconds                   |

---

## Credentials

Contact the intelinteract team to obtain your `tenantId` and `widgetId`.

</details>

---

## Notes

- The phone number input accepts **digits only** — do not include the country code (e.g. enter `9876543210`, not `+919876543210`). The country code is selected separately via the picker.
- The floating button can be **dragged** anywhere on screen and snaps to the nearest edge on release.
- Pass `fabX` and `fabY` to `initialize()` / `init()` to set the button's **initial position** (in points from the top-left corner). Defaults to bottom-right if omitted.
- Call and chat features are individually toggled by the widget configuration fetched from the server.
- Microphone and camera permissions are requested at runtime when the user initiates a call.
- When `providerType` is `APP_CONNECT`, call `setToken()` as soon as your user's token is available. The SDK buffers the token internally and applies it once the widget config has been fetched, so there is no need to wait for `initialize()` to complete before calling `setToken()`.
