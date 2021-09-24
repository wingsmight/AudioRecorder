//
//  AudioRecorderApp.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import SwiftyStoreKit

@main
struct AudioRecorderApp: App {
    var body: some Scene {
        WindowGroup {
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
        }
    }
}
