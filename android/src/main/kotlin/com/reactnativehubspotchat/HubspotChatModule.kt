package com.reactnativehubspotchat

import android.app.Activity
import com.facebook.react.bridge.*
import com.hubspot.mobile.sdk.HubspotManager

class HubspotChatModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "HubspotModule"
  }

  @ReactMethod
  fun initSDK(promise: Promise) {
    try {
      HubspotManager.initialize(reactApplicationContext)
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("INIT_ERROR", "Failed to initialize HubSpot SDK", e)
    }
  }

  @ReactMethod
  fun openChat(tag: String, promise: Promise) {
    try {
      val activity: Activity? = currentActivity
      if (activity != null) {
        HubspotManager.showChat(activity, tag)
        promise.resolve(null)
      } else {
        promise.reject("NO_ACTIVITY", "No current activity")
      }
    } catch (e: Exception) {
      promise.reject("CHAT_ERROR", "Failed to open HubSpot chat", e)
    }
  }

  @ReactMethod
  fun identifyVisitor(identityToken: String, email: String?, promise: Promise) {
    HubspotManager.setUserIdentity(identityToken, email)
    promise.resolve(null)
  }

  @ReactMethod
  fun setChatProperties(properties: ReadableMap, promise: Promise) {
    val map = mutableMapOf<String, String>()
    val iterator = properties.keySetIterator()
    while (iterator.hasNextKey()) {
      val key = iterator.nextKey()
      map[key] = properties.getString(key) ?: ""
    }
    HubspotManager.setChatProperties(map)
    promise.resolve(null)
  }

  @ReactMethod
  fun endSession(promise: Promise) {
    try {
      HubspotManager.logout()
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("LOGOUT_ERROR", "Failed to logout", e)
    }
  }
}