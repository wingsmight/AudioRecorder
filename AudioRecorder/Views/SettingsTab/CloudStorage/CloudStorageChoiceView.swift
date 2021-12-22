//
//  CloudStorageChoiceView.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import SwiftUI

struct CloudStorageChoiceView: View {
    @Binding var isShowing: Bool
    
    
    @AppStorage("availableStorageSize") private var availableStorageSize: Int = CloudDatabase.Plan.free200MB.size

    
    
    var body: some View {
        NavigationView {
            ScrollView {
                Button {
                    CloudDatabase.changeStoragePlan(user:  AppAuth().currentUser!, newPlan: CloudDatabase.Plan.paid2GB) {
                        fatalError("\(CloudDatabase.Plan.paid2GB) cannot be bought. Please contact support")
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
}

struct CloudStorageChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CloudStorageChoiceView(isShowing: .constant(true))
    }
}
