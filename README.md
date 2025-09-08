# React Native HubSpot Chat

[![mit licence](https://img.shields.io/dub/l/vibe-d.svg?style=for-the-badge)](https://github.com/Saranshmalik/react-native-hubspot-chat/blob/main/LICENSE)
[![npm version](https://img.shields.io/npm/v/react-native-hubspot-chat)](https://www.npmjs.org/package/react-native-hubspot-chat)
<br />
[![platform - android](https://img.shields.io/badge/platform-Android-3ddc84.svg?logo=android&style=for-the-badge)](https://www.android.com)
[![platform - ios](https://img.shields.io/badge/platform-iOS-000.svg?logo=apple&style=for-the-badge)](https://developer.apple.com/ios)

A React Native wrapper for the **HubSpot Mobile Chat SDK** for both iOS and Android.

This package internally uses the official SDK provided by hubspot:
iOS: https://github.com/HubSpot/mobile-chat-sdk-ios
Android: https://github.com/HubSpot/mobile-chat-sdk-android

This package allows you to integrate **HubSpot's Mobile Chatflow** into your React Native app, with clean API, full TypeScript support, and native performance.

---

## ✅ Features

- 📱 Supports **iOS (Swift)** and **Android (Kotlin)**
- ✅ Native module bridge using TurboModules compatibility
- 🎯 Supports **TypeScript**
- 💬 Chatflow integration with a single method
- 🔐 Visitor identification supported
- 🔔 Push notifications (APNs/FCM) support with helpers and events
- 📦 Includes full documentation and open to contributions

---

## ⚙️ Setup

### iOS
You need to get your plist file with hubspot configuration from your hubspot account. This is required for the chat to work. 

**Note:The naming of the file should be exactly as mentioned below.**

1. Add `Hubspot-Info.plist` to your iOS project:
   - Open Xcode → Right-click on the app → `Add Files to [YourApp]...`
   - Select `Hubspot-Info.plist`
   - Make sure the file is added to the main app target (check the checkbox)

2. Install pods:

```sh
cd ios && pod install
```

---

### Android

1. Download your `hubspot-info.json` file from Hubspot Console
2. Place it inside `android/app/src/main/assets/` (Create this folder if not already existing)

---

## 🚀 Installation

```sh
yarn add react-native-hubspot-chat
cd ios && pod install
```

---

## 🧪 Usage

### Initialize SDK

Initialise the SDK at the start of the app, please ensure your ios and android conifguration is done properly or this will fail.

```js
import HubspotChat from 'react-native-hubspot-chat';
await HubspotChat.init();
```

### Identify Visitor

You would need to have an identity token from hubspot first. Please read here for more details:
https://developers.hubspot.com/docs/guides/api/conversations/mobile-chat-sdk/ios#identify-users-with-the-hubspot-visitor-identification-token

```js
await HubspotChat.identify('your_signed_identity_token', 'user@example.com');
```

### Set custom chat properties

```js
await HubspotChat.setProperties([
  { name: 'plan', value: 'pro' },
  { name: 'theme', value: 'dark' }
]);
```

### Open Chat

```js
await HubspotChat.open('your-chatflow-tag');
```

### Push Notifications

#### iOS

1) Call `configurePushMessaging` early in app startup to set up the notification delegate and optionally request permission.

```js
import HubspotChat from 'react-native-hubspot-chat';

await HubspotChat.configurePushMessaging({ prompt: false, allowProvisional: true });
```

2) Forward the APNs device token to the SDK from your `AppDelegate`.

```objectivec
// AppDelegate.m
#import <React/RCTBridge.h>
#import <React/RCTRootView.h>
#import <React/RCTBridgeModule.h>

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  RCTBridge *bridge = [(RCTRootView *)self.window.rootViewController.view bridge];
  id<NSObject> module = [bridge moduleForName:@"HubspotModule" lazilyLoadIfNecessary:YES];
  if ([module respondsToSelector:@selector(setAPNsDeviceToken:resolver:rejecter:)]) {
    // Call the native method directly
    void (*msgSend)(id, SEL, NSData *, RCTPromiseResolveBlock, RCTPromiseRejectBlock) = (void *)objc_msgSend;
    msgSend(module, @selector(setAPNsDeviceToken:resolver:rejecter:), deviceToken, ^(id _) {}, ^(NSString *code, NSString *msg, NSError *err) {});
  }
}
```

Alternatively in Swift apps, you can call `HubspotModule.setAPNsDeviceToken(deviceToken)` from native, or convert the token to hex and call `HubspotChat.setPushToken(hex)` from JS.

3) Listen for new message tap events to open chat with the provided chatflow.

```js
import { useEffect } from 'react';
import HubspotChat from 'react-native-hubspot-chat';

useEffect(() => {
  const sub = HubspotChat.addNewMessageListener(({ chatflow }) => {
    if (chatflow) HubspotChat.open(chatflow);
  });
  return () => sub.remove();
}, []);
```

#### Android

1) Ensure FCM is configured and `hubspot-info.json` is added under `android/app/src/main/assets/`.

2) From your `FirebaseMessagingService` (or subclass the provided `HubspotFirebaseMessagingService` in the native SDK), forward the token when received:

```kotlin
// In your FirebaseMessagingService
override fun onNewToken(token: String) {
  super.onNewToken(token)
  HubspotChat.setPushToken(token)
}
```

The native SDK will show a notification and route taps to the HubSpot web activity.

---

## 🧩 TypeScript Support

This module includes `.d.ts` definitions out-of-the-box.

```ts
HubspotChat.init(): Promise<void>;
HubspotChat.open(tag: string): Promise<void>;
HubspotChat.identify(identityToken: string, email?: string): Promise<void>;
HubspotChat.setProperties(props: { name: string; value: string }[] | Record<string, string>): Promise<void>;
HubspotChat.endSession(): Promise<void>;
// Push
HubspotChat.configurePushMessaging(options?: { prompt?: boolean; allowProvisional?: boolean }): Promise<void>;
HubspotChat.setPushToken(token: string): Promise<void>;
HubspotChat.addNewMessageListener(handler: (data: { portalId?: string; chatflowId?: string; threadId?: string; chatflow?: string }) => void): { remove: () => void };
```

---

## 📁 Files to Include

| File                  | Platform | Required |
|-----------------------|----------|----------|
| `hubspot-info.json` | Android | ✅       |
| `Hubspot-Info.plist`   | iOS     | ✅       |

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development instructions.

---

## 📄 License

MIT – see [LICENSE](LICENSE)