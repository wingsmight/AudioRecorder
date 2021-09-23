//
//  PaidCloudPlanView.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import SwiftUI

struct PaidCloudPlanView: View {
    @State var isPressed = false
    
    
    var body: some View {
        ZStack(alignment: Alignment.top) {
            Color("cloudPlanBackgroundColor")
                .opacity(isPressed ? 0.5 : 0.3)
                .blur(radius: 20)
            VStack {
                HStack {
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                        .foregroundColor(Color("paidCloudColor"))
                    Spacer()
                    VStack {
                        Text("2 GB")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                            .foregroundColor(Color("paidCloudColor"))
                            .shadow(color: .secondary.opacity(0.8), radius: 10)
                        Text("99.99 $")
                            .font(SwiftUI.Font.headline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .cornerRadius(20)
        .padding(.leading)
        .padding(.trailing)
        .padding(.bottom, 3)
        .padding(.top, 3)
        .shadow(radius: 20)
//        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { isPressing in
//            withAnimation(.easeInOut(duration: 1.0)) {
//                self.isPressed = isPressing
//            }
//            if isPressing {
//                print("My long pressed starts")
//            } else {
//                print("My long pressed ends")
//            }
//        }, perform: { })
    }
}

struct PaidCloudPlanView_Previews: PreviewProvider {
    static var previews: some View {
        PaidCloudPlanView()
    }
}
