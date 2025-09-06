import Foundation
import React
import HubspotMobileSDK
import SwiftUI

@objc(HubspotModule)
class HubspotModule: NSObject {

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

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
}