package com.reactnativehubspotchat

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.content.Context
import android.content.Intent
import com.facebook.react.bridge.*
import com.hubspot.mobilesdk.HubspotManager
import kotlinx.coroutines.*
import android.util.Log
import com.hubspot.mobilesdk.HubspotWebActivity
import com.facebook.react.modules.core.DeviceEventManagerModule

class HubspotChatModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String = "HubspotModule"
  private val appContext: Context = reactContext
  private lateinit var hubspotManager: HubspotManager

  @ReactMethod
    fun initSDK(promise: Promise) {
      try {
        hubspotManager = HubspotManager.getInstance(appContext)
        hubspotManager?.enableLogs()
        hubspotManager?.configure()
        promise.resolve(true)
      } catch (e: Exception) {
        Log.e("HubspotModule", "Failed to init SDK", e)
        promise.reject("INIT_ERROR", e.message, e)
      }
    }

  @ReactMethod
  fun openChat(tag:String, promise: Promise) {
      try {
        val intent = Intent(appContext, HubspotWebActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) // Required when starting from non-activity context
        appContext.startActivity(intent)
        promise.resolve(null)
      } catch (e: Exception) {
        Log.e("HubspotModule", "Error opening chat: ${e.message}")
        promise.reject("CHAT_ERROR", "Failed to open chat", e)
      }
  }

  @ReactMethod
  fun identifyVisitor(identityToken: String, email: String?, promise: Promise) {
    try {
      hubspotManager.setUserIdentity(identityToken, email ?: "")
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("IDENTIFY_FAILED", e)
    }
  }

  @ReactMethod
  fun setChatProperties(props: ReadableMap, promise: Promise) {
    try {
      val keyValuePair = mutableMapOf<String, String>()
      val iterator = props.keySetIterator()
      while (iterator.hasNextKey()) {
        val key = iterator.nextKey()
        keyValuePair[key] = props.getString(key) ?: ""
      }
      hubspotManager.setChatProperties(keyValuePair)
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("SET_PROPERTIES_FAILED", e)
    }
  }

  @ReactMethod
  fun endSession(promise: Promise) {
    CoroutineScope(Dispatchers.Main).launch {
      try {
        hubspotManager.logout()
        promise.resolve(null)
      } catch (e: Exception) {
        promise.reject("LOGOUT_FAILED", e)
      }
    }
  }

  // region Push Notifications
  @ReactMethod
  fun setPushToken(token: String, promise: Promise) {
    CoroutineScope(Dispatchers.Main).launch {
      try {
        hubspotManager.setPushToken(token)
        promise.resolve(null)
      } catch (e: Exception) {
        promise.reject("SET_PUSH_TOKEN_FAILED", e)
      }
    }
  }
  // endregion

  // region RN Event Emitter compatibility (prevents warnings on JS side)
  @ReactMethod
  fun addListener(eventName: String) {
    // No-op: required to conform to React Native's NativeEventEmitter expectations
  }

  @ReactMethod
  fun removeListeners(count: Int) {
    // No-op
  }
  // endregion

}

