//
//  CustomEventEmitter.swift
//  react-native-modifier
//
//  Created by MacBook on 10/09/24.
//

import Foundation

@objc(CustomEventEmitter)
class CustomEventEmitter: RCTEventEmitter {
    
    static var shared: CustomEventEmitter?

    override init() {
        super.init()
        CustomEventEmitter.shared = self
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override func supportedEvents() -> [String] {
        return ["onSigninComplete", "onSigninFail"]
    }

    // Delegate method callback
    func onAppleSigninSuccess(_ result: [AnyHashable : Any]?) {
        // Emit event to React Native
        sendEvent(withName: "onSigninComplete", body: result)
    }
    
    func onAppleSigninError(_ error: Error?) {
        // Emit event to React Native
        sendEvent(withName: "onSigninFail", body: error?.localizedDescription)
    }
}
