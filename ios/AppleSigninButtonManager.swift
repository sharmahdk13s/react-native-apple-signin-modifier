//
//  AppleSigninButton.swift
//  react-native-modifier
//
//  Created by MacBook on 04/09/24.
//

import Foundation
import SwiftUI
import AuthenticationServices

@objc(AppleSigninButtonManager)
class AppleSigninButtonManager: RCTViewManager {

  override class func requiresMainQueueSetup() -> Bool {
    return true
  }
    override func view() -> ASAuthorizationAppleIDButton? {
      let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .whiteOutline)
      button.backgroundColor = .clear
        button.addTarget(self, action: #selector(appleSigninClick), for: .touchUpInside)
      return button
  }

    @objc private func appleSigninClick() {
        AppleSignInManager.shared.startSignInWithAppleFlow(appleBtn: true)
    }
}
