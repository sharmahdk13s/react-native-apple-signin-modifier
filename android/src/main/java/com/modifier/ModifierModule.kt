package com.modifier

import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentManager
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import org.json.JSONObject
import java.security.MessageDigest
import java.util.UUID

@ReactModule(name = ModifierModule.NAME)
class ModifierModule(reactContext: ReactApplicationContext) :   NativeModifierSpec(reactContext) {
  private val E_NOT_CONFIGURED_ERROR = "E_NOT_CONFIGURED_ERROR"
  private val E_SIGNIN_FAILED_ERROR = "E_SIGNIN_FAILED_ERROR"
  private val E_SIGNIN_CANCELLED_ERROR = "E_SIGNIN_CANCELLED_ERROR"


  private var configuration: SignInWithAppleConfiguration? = null

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  override fun methodModifier(a: Double, b: Double, promise: Promise) {
    if (promise != null) {
      return promise.resolve(a * b)
    };
  }


  private fun getFragmentManagerHelper(): FragmentManager? {
    val activity = getCurrentActivity()
    return if (activity is FragmentActivity) {
      activity.supportFragmentManager
    } else {
      null
    }
  }

  private fun bytesToHex(hash: ByteArray): String {
    val hexString = StringBuilder()
    for (i in hash.indices) {
      hexString.append(Character.forDigit((hash[i].toInt() shr 4) and 0xF, 16))
      hexString.append(Character.forDigit((hash[i].toInt() and 0xF), 16))
    }
    return hexString.toString()
  }

  override fun configureSignin(configObject: ReadableMap?, promise: Promise?) {
    var clientId = ""
    var redirectUri = ""
    var scope = SignInWithAppleConfiguration.Scope.ALL
    var responseType = SignInWithAppleConfiguration.ResponseType.ALL
    var state = UUID.randomUUID().toString()
    val nonceEnabled = if ((configObject as ReadableMap).hasKey("nonceEnabled")) configObject.getBoolean("nonceEnabled") else true
    var rawNonce = ""
    var nonce = ""

    if (configObject.hasKey("clientId")) {
        clientId = configObject.getString("clientId") ?: ""
      }

    if (configObject.hasKey("redirectUri")) {
      redirectUri = configObject.getString("redirectUri") ?: ""
    }

    if (configObject.hasKey("scope")) {
        val scopeString = configObject.getString("scope")
        if (scopeString != null) {
          scope = SignInWithAppleConfiguration.Scope.valueOf(scopeString)
        }
      }

    if (configObject.hasKey("responseType")) {
        val responseTypeString = configObject.getString("responseType")
        if (responseTypeString != null) {
          responseType = SignInWithAppleConfiguration.ResponseType.valueOf(responseTypeString)
        }
      }

    if (configObject.hasKey("state")) {
        state = configObject.getString("state") ?: state
      }

    if (nonceEnabled) {
      if (configObject.hasKey("nonce")) {
          nonce = configObject.getString("nonce") ?: ""
          rawNonce = nonce
        } else {
          // If no nonce is provided, generate one
          nonce = UUID.randomUUID().toString()
          rawNonce = nonce
        }

      // SHA256 of the nonce to keep in line with the iOS library (and avoid confusion)
      try {
        val md = MessageDigest.getInstance("SHA-256")
        md.update(nonce.toByteArray())
        val digest = md.digest()
        nonce = bytesToHex(digest)
      } catch (e: Exception) {
      }
    }

    this.configuration = SignInWithAppleConfiguration.Builder()
      .clientId(clientId)
      .redirectUri(redirectUri)
      .responseType(SignInWithAppleConfiguration.ResponseType.ALL)
      .scope(SignInWithAppleConfiguration.Scope.ALL)
      .state(state)
      .rawNonce(rawNonce)
      .nonce(nonce)
      .build()

    if (promise != null) {
      return promise.resolve(true)
    };
  }



  override fun signInWithApple(promise: Promise?) {
    if (this.configuration == null) {
      promise?.reject(E_NOT_CONFIGURED_ERROR)
      return
    }
    val fragmentManager = this.getFragmentManagerHelper()

    if (fragmentManager == null) {
      promise?.reject(E_NOT_CONFIGURED_ERROR)
      return
    }

    val callback = object : SignInWithAppleCallback {
      override fun onSignInWithAppleSuccess(code: String, id_token: String, state: String, user: String) {
        val response = Arguments.createMap()
        response.putString("code", code)
        response.putString("id_token", id_token)
        response.putString("state", state)

        val rawNonce = configuration!!.rawNonce
        if (rawNonce.isNotEmpty()) {
          response.putString("nonce", rawNonce)
        }

        try {
          val userJSON = JSONObject(user)
          val userMap = Arguments.createMap()
          if (userJSON.has("name")) {
            val nameJSON = userJSON.getJSONObject("name")
            val nameMap = Arguments.createMap()
            if (nameJSON.has("firstName")) {
              nameMap.putString("firstName", nameJSON.getString("firstName"))
            }
            if (nameJSON.has("lastName")) {
              nameMap.putString("lastName", nameJSON.getString("lastName"))
            }
            if (nameMap.hasKey("firstName") || nameMap.hasKey("lastName")) {
              userMap.putMap("name", nameMap)
            }
          }
          if (userJSON.has("email")) {
            userMap.putString("email", userJSON.getString("email"))
          }
          if (userMap.hasKey("name") || userMap.hasKey("email")) {
            response.putMap("user", userMap)
          }
        } catch (e: Exception) {
        }
        promise?.resolve(response)
      }

      override fun onSignInWithAppleFailure(error: Throwable) {
        promise?.reject(E_SIGNIN_FAILED_ERROR, error)
      }

      override fun onSignInWithAppleCancel() {
        promise?.reject(E_SIGNIN_CANCELLED_ERROR)
      }
    }

    val fragmentTag = "SignInWithAppleButton-${com.facebook.react.R.id.rn_frame_method}-SignInWebViewDialogFragment"
    val service = SignInWithAppleService(
      fragmentManager,
      fragmentTag,
      configuration!!,
      callback
    )

    val activity = getCurrentActivity()
    if (activity == null) {
      promise?.reject(RuntimeException("Activity is not found"))
    } else {
      activity.runOnUiThread {
        service.show()
      }
    }
  }
  companion object {
    const val NAME = "Modifier"
  }
}
