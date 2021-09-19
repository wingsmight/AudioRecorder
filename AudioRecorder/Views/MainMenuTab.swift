//
//  MainMenuTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import ToastUI
import SwiftUI

struct MainMenuTab: View {
    @State private var isRecording: Bool = false
    @State private var recordingButtonImage = "play.fill"
    
    
    var body: some View {
        Button(action: {
            self.isRecording.toggle()
            self.recordingButtonImage = isRecording ? "stop.fill" : "play.fill"
            }) {
            Image(systemName: recordingButtonImage)
                .frame(width: 100, height: 100)
                .foregroundColor(Color.white)
                .background(Color.green)
                .font(.system(size: 50))
                .clipShape(Circle())
        }
        .toast(isPresented: $isRecording, dismissAfter: 2.0) {
            VStack {
                Spacer()
                Text("Приложение запущено")
            }
        }
    }
}

struct MainMenuTab_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuTab()
    }
}
