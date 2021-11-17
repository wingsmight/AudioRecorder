//
//  AudioRecorderApp.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import SwiftyStoreKit
import Firebase

@main
struct AudioRecorderApp: App {
    @EnvironmentObject var appAuth: AppAuth
    
    
    public init() {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        let appAuth = AppAuth()
        
        WindowGroup {
            AuthGateView()
                .environmentObject(appAuth)
                .onAppear {
                    // color scheme
                    Theme.colorScheme = Theme.colorScheme
                    
                    // in-app purchases
                    SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
                        for purchase in purchases {
                            switch purchase.transaction.transactionState {
                            case .purchased, .restored:
                                if purchase.needsFinishTransaction {
                                    // Deliver content from server, then:
                                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                                }
                                // Unlock content
                            case .failed, .purchasing, .deferred:
                                break // do nothing
                            @unknown default:
                                fatalError()
                            }
                        }
                    }
                    
                    let userDefaults = UserDefaults.standard
                    
                    // log out if detect first launch
                    if (!userDefaults.bool(forKey: "hasRunBefore")) {
                        print("The app is launching for the first time. Setting UserDefaults...")

                        do {
                            appAuth.signOut()
                        } catch {

                        }

                        // Update the flag indicator
                        userDefaults.set(true, forKey: "hasRunBefore")
                        userDefaults.synchronize() // This forces the app to update userDefaults

                        // Run code here for the first launch

                    } else {
                        print("The app has been launched before. Loading UserDefaults...")
                        // Run code here for every other launch but the first
                    }
                }
        }
    }
}
