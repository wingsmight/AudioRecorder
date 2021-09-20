//
//  MainMenuTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI


struct MainMenuTab: View {
    @Binding var isRecordingToastShowing : Bool
    @Binding var isRecording : Bool
    
    
    var recordingButtonImage : String {
        return self.isRecording ? "stop.fill" : "play.fill"
    }
    
   
    var body: some View {
        VStack {
            Button(action: {
                isRecording.toggle()
                isRecordingToastShowing = isRecording
                }) {
                Image(systemName: recordingButtonImage)
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .font(.system(size: 50))
                    .clipShape(Circle())
            }
        }
    }
}

struct MainMenuTab_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuTab(isRecordingToastShowing: .constant(false), isRecording: .constant(false))
    }
}
