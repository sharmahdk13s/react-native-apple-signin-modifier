//
//  AppleSignInManager.swift
//  SDiWatch
//
//  Created by MacBook on 20/08/24.
//

import Foundation
import AuthenticationServices

class AppleSignInManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    static let shared = AppleSignInManager()
    
    var isFromAppleButton : Bool = false
    var resolveCallback: RCTPromiseResolveBlock?
    // Singleton instance
    var onCompletion: ((Result<ASAuthorization, Error>) -> Void)?
    
    // ASAuthorizationControllerDelegate methods
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        onCompletion?(.success(authorization))
        if(isFromAppleButton){
            let appleIdCredentials = authorization.credential as? ASAuthorizationAppleIDCredential
            CustomEventEmitter.shared?.onAppleSigninSuccess(convertCredentials(from: appleIdCredentials))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onCompletion?(.failure(error))
        if(isFromAppleButton){
            CustomEventEmitter.shared?.onAppleSigninError(error)
        }
    }
    
    // ASAuthorizationControllerPresentationContextProviding method
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // This is a safer way to get the key window.
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) ?? UIWindow()
    }
    
    @objc 
    func startSignInWithAppleFlow(appleBtn isAppleButtonClick: Bool) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.requestedOperation = ASAuthorization.OpenIDOperation.operationImplicit
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        isFromAppleButton = isAppleButtonClick
    }
    
    @objc
    func convertCredentials(from appleIdCredential: ASAuthorizationAppleIDCredential?) -> [AnyHashable : Any]? {
        var identityToken: String?
        if appleIdCredential?.value(forKey: "identityToken") != nil {
            if let value = appleIdCredential?.value(forKey: "identityToken") as? Data {
                identityToken = String(
                    data: value,
                    encoding: .utf8)
            }
        }
        
        var authorizationCode: String?
        if appleIdCredential?.value(forKey: "authorizationCode") != nil {
            if let value = appleIdCredential?.value(forKey: "authorizationCode") as? Data {
                authorizationCode = String(
                    data: value,
                    encoding: .utf8)
            }
        }
        
        var fullName: NSMutableDictionary?

        if let appleIDCredentialFullName = appleIdCredential?.fullName {
            // Create a dictionary manually from PersonNameComponents
            let fullNameDictionary: [String: Any] = [
                "namePrefix": appleIDCredentialFullName.namePrefix ?? NSNull(),
                "givenName": appleIDCredentialFullName.givenName ?? NSNull(),
                "middleName": appleIDCredentialFullName.middleName ?? NSNull(),
                "familyName": appleIDCredentialFullName.familyName ?? NSNull(),
                "nameSuffix": appleIDCredentialFullName.nameSuffix ?? NSNull(),
                "nickname": appleIDCredentialFullName.nickname ?? NSNull()
            ]

            // Convert to NSMutableDictionary
            fullName = NSMutableDictionary(dictionary: fullNameDictionary)

            // Print or use the fullName dictionary
            print(fullName ?? "No full name available")
        }
        
        return [
            "user": appleIdCredential!.user,
            "fullName": fullName as Any,
            "realUserStatus": NSNumber(value: appleIdCredential!.realUserStatus.rawValue),
            "authorizedScopes": appleIdCredential!.authorizedScopes,
            "identityToken": identityToken as Any,
            "email": appleIdCredential?.email ?? "",
            "state": appleIdCredential?.state ?? "",
            "authorizationCode": authorizationCode ?? "",
        ]
    }
}
