//
//  AppleSignin.swift
//  react-native-modifier
//
//  Created by MacBook on 03/09/24.
//
import Foundation
import AuthenticationServices

@objc(AppleSignin)
public class AppleSignin: NSObject {
    
    @objc
    public func signInWithApple(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        AppleSignInManager.shared.startSignInWithAppleFlow(appleBtn: false)
        // Simulate an asynchronous operation, e.g., a network request
        DispatchQueue.global().async {
            AppleSignInManager.shared.onCompletion = { result in
                switch result {
                case .success(let authorization):
                    // Handle authorization success, possibly updating authViewModel
                    resolve(self.handleAuthorization(authorization: authorization))
                case .failure(let error):
                    // Handle error
                    print("Authorization failed: \(error)")
                    let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Task failed"])
                    reject("Failed", "Task failed!", error)
                }
            }
        }
    }
    
    private func handleAuthorization(authorization: ASAuthorization) -> [AnyHashable : Any]? {
        if authorization.credential is ASAuthorizationAppleIDCredential {
            let appleIdCredentials = authorization.credential as? ASAuthorizationAppleIDCredential
            return AppleSignInManager.shared.convertCredentials(from: appleIdCredentials)
        } else {
            return nil
        }
    }
}
