//
//  CloudStorageChoiceView.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import SwiftUI
import SwiftyStoreKit

struct CloudStorageChoiceView: View {
    @Binding var isShowing: Bool
    
    
    @AppStorage("availableStorageSize") private var availableStorageSize: Int = CloudDatabase.Plan.free200MB.size

    
    
    var body: some View {
        NavigationView {
            ScrollView {
                Button {
                    buyStorage(plan: CloudDatabase.Plan.paid2GB) {
                        
                    }
                } label: {
                    PaidCloudPlanView()
                }
                .disabled(availableStorageSize >= CloudDatabase.Plan.paid2GB.size)
                .padding(.top, 10)
                
                Spacer()
                
                FreeCloudPlanView()
            }
            .navigationBarTitle(Text("Размер облака"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.isShowing = false
            }, label: {
                Text("Готово").bold()
            }))
        }
    }
    
    private func buyStorage(plan: CloudDatabase.Plan, onSuccess: @escaping () -> Void) {
        let boughtProduct = Store.products["CloudStorage_\(plan)"];
        print("product = \(boughtProduct)")
        
        SwiftyStoreKit.purchaseProduct(boughtProduct!, quantity: 1, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server
                CloudDatabase.changeStoragePlan(user: AppAuth().currentUser!, newPlan: plan) {
                    // then finish transaction
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                    
                    print("Purchase Success: \(product.transaction)")
                    onSuccess()
                }
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError))
                }
            }
        }
    }
}

struct CloudStorageChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CloudStorageChoiceView(isShowing: .constant(true))
    }
}
