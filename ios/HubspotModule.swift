import Foundation
import React
import HubspotMobileSDK
import SwiftUI

@objc(HubspotModule)
class HubspotModule: RCTEventEmitter {

  @objc
  func initSDK(_ resolve: @escaping RCTPromiseResolveBlock,
               rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      do {
        try HubspotManager.configure()
        resolve(nil)
      } catch {
        reject("INIT_ERROR", "Hubspot configuration failed", error)
      }
    }
  }

  @objc
  func openChat(_ tag: String,
                resolver resolve: @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      guard let rootVC = UIApplication.shared.delegate?.window??.rootViewController else {
        reject("NO_UI", "No root view controller", nil)
        return
      }

      let chatView = HubspotChatView(chatFlow: tag)
      let hostingController = UIHostingController(rootView: chatView)
      rootVC.present(hostingController, animated: true) {
        resolve(nil)
      }
    }
  }

  // Expose to React Native with explicit selector matching HubspotModule.m
  @objc(identifyVisitor:email:resolver:rejecter:)
  func identifyVisitor(_ identityToken: String, email: String?,
                      resolver resolve: @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {
      DispatchQueue.main.async {
      HubspotManager.shared.setUserIdentity(identityToken: identityToken, email: email ?? "")
      resolve(nil)
    }
  }

  @objc
  func setChatProperties(_ properties: [[String: Any]],
                        resolver resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
    var map = [String: String]()
    for item in properties {
      if let name = item["name"] as? String, let value = item["value"] as? String {
        map[name] = value
      }
    }

    Task {
      await HubspotManager.shared.setChatProperties(data: map)
      resolve(nil)
    }
  }

  @objc
  func endSession(_ resolve: @escaping RCTPromiseResolveBlock,
                  rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task {
      await HubspotManager.shared.clearUserData()
      resolve(nil)
    }
  }

  // MARK: - Push Notifications

  /// Configure push messaging and optionally prompt for permissions. Also sets up a callback to forward new message events to JS.
  /// - Parameters:
  ///   - promptForNotificationPermissions: If true, prompt user for notification permission when not determined
  ///   - allowProvisional: If true and prompt is false, enable provisional notifications when not determined
  @objc(configurePushMessaging:allowProvisional:resolver:rejecter:)
  func configurePushMessaging(_ promptForNotificationPermissions: Bool,
                              allowProvisional: Bool,
                              resolver resolve: @escaping RCTPromiseResolveBlock,
                              rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      HubspotManager.shared.configurePushMessaging(
        promptForNotificationPermissions: promptForNotificationPermissions,
        allowProvisionalNotifications: allowProvisional,
        newMessageCallback: { [weak self] pushData in
          guard let self = self else { return }
          let payload: [String: Any] = [
            "portalId": pushData.portalId as Any,
            "chatflowId": pushData.chatflowId as Any,
            "threadId": pushData.threadId as Any,
            "chatflow": pushData.chatflow as Any
          ].compactMapValues { $0 }
          self.sendEvent(withName: "HubspotNewMessage", body: payload)
        }
      )
      resolve(nil)
    }
  }

  /// Set the APNs device token (hex string) so it can be registered with HubSpot
  @objc(setPushToken:resolver:rejecter:)
  func setPushToken(_ tokenHex: String,
                    resolver resolve: @escaping RCTPromiseResolveBlock,
                    rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      guard let tokenData = Self.dataFromHexString(tokenHex) else {
        reject("TOKEN_FORMAT", "Invalid APNs token hex string", nil)
        return
      }
      HubspotManager.shared.setPushToken(apnsPushToken: tokenData)
      resolve(nil)
    }
  }

  /// Set the APNs device token (NSData) directly from AppDelegate
  @objc(setAPNsDeviceToken:resolver:rejecter:)
  func setAPNsDeviceToken(_ deviceToken: Data,
                          resolver resolve: @escaping RCTPromiseResolveBlock,
                          rejecter reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      HubspotManager.shared.setPushToken(apnsPushToken: deviceToken)
      resolve(nil)
    }
  }

  private static func dataFromHexString(_ hex: String) -> Data? {
    let trimmed = hex.replacingOccurrences(of: " ", with: "").lowercased()
    guard trimmed.count % 2 == 0 else { return nil }
    var data = Data(capacity: trimmed.count / 2)
    var index = trimmed.startIndex
    while index < trimmed.endIndex {
      let nextIndex = trimmed.index(index, offsetBy: 2)
      let byteString = trimmed[index..<nextIndex]
      if let num = UInt8(byteString, radix: 16) {
        data.append(num)
      } else {
        return nil
      }
      index = nextIndex
    }
    return data
  }

  // MARK: - RCTEventEmitter

  override func supportedEvents() -> [String]! {
    return ["HubspotNewMessage"]
  }

  @objc override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  override func startObserving() {
    // No-op
  }

  override func stopObserving() {
    // No-op
  }

  @objc
  override static func moduleName() -> String! { return "HubspotModule" }
}