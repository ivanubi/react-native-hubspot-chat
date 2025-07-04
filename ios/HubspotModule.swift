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

  @objc
  func identifyVisitor(_ email: String, name: String,
                       resolver resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) {
    HubspotManager.shared.identify(email: email, name: name)
    resolve(nil)
  }

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
}