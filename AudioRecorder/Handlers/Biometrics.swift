//
//  Biometrics.swift
//  AudioRecorder
//
//  Created by Igoryok on 13.01.2022.
//

import Foundation
import LocalAuthentication


public class Biometrics {
    public static func isAvailable(reason: String, onPerform: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                if let authenticationError = authenticationError {
                    let laError = authenticationError as! LAError
                    if laError.code == LAError.Code.userFallback {
                        print("laError.code = \(laError.code)")
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                            print("0onPerform = \(success)")
                            onPerform(success)
                        }
                    } else {
                        print("1onPerform = \(success)")
                        onPerform(success)
                    }
                } else {
                    print("2onPerform = \(success)")
                    onPerform(success)
                }
            }
        } else {
            // no biometrics
            if error != nil {
                print("No biometrics = \(error)")
                let laError = error as! LAError
                print("laError.code = \(laError.code)")
                if laError.code == LAError.Code.touchIDLockout {
                    print("3onPerform = \(false)")
                    onPerform(false)
                    
                    print("WARNING. Phone has been hacking!")
                    return
                }
            }
            print("4onPerform = \(true)")
            onPerform(true)
        }
    }
}
