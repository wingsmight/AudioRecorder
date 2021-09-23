//
//  CloudStorageChoiceView.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import SwiftUI

struct CloudStorageChoiceView: View {
    @Binding var isShowing: Bool
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                Button {
                    
                } label: {
                    PaidCloudPlanView()
                }
                .padding(.top, 10)
                
                Spacer()
                
                Button {
                    
                } label: {
                    FreeCloudPlanView()
                }
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
