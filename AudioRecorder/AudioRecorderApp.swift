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
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    public init() {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        let appAuth = AppAuth()
        
        WindowGroup {
            if appAuth.signedIn {
                ContentView()
                    .onAppear {
                        Theme.colorScheme = Theme.colorScheme
                        
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
                    }
                    .environmentObject(appAuth)
            } else {
                LogInView()
                    .onAppear {
                        Theme.colorScheme = Theme.colorScheme
                        
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
                    }
                    .environmentObject(appAuth)
            }
        }
    }
    
    func initialize(appAuth: AppAuth) {

    }
}

//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//
//        return true
//    }
//}
