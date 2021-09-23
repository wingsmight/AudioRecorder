//
//  FreeCloudPlanView.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import SwiftUI

struct FreeCloudPlanView: View {
    var body: some View {
        ZStack(alignment: Alignment.top) {
            Color(UIColor.gray)
                .opacity(0.15)
            VStack {
                HStack {
                    Image(systemName: "cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                        .foregroundColor(Color(UIColor.darkGray))
                    Spacer()
                    VStack {
                        Text("200 MB")
                            .foregroundColor(Color(UIColor.darkGray))
                            .font(.title)
                            .padding()
                        Text("--.-- $")
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
    }
}

struct FreeCloudPlanView_Previews: PreviewProvider {
    static var previews: some View {
        FreeCloudPlanView()
    }
}
