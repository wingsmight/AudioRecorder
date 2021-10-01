//
//  MainMenuTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import AVKit


struct MainMenuTab: View {
    @Binding var isRecordingToastShowing : Bool
    
    @ObservedObject var audioRecorder: AudioRecorder
    
    
    @AppStorage("recordCount") private var recordCount = 0;
    
    
    var recordingButtonImage : String {
        return self.IsRecording ? "stop.fill" : "play.fill"
    }
    
    
    var body: some View {
        VStack {
            Button(action: {
                isRecordingToastShowing = IsRecording
                
                if IsRecording {
                    audioRecorder.stopRecording();
                    self.recordCount += 1
                } else {
                    audioRecorder.startRecording()
                }
            }) {
                Image(systemName: recordingButtonImage)
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.white)
                    .background(Color.green)
                    .font(.system(size: 50))
                    .clipShape(Circle())
            }
        }
        .navigationTitle("Аудиорегистратор")
    }
    
    var IsRecording: Bool {
        audioRecorder.recording
    }
}

struct MainMenuTab_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuTab(isRecordingToastShowing: .constant(false), audioRecorder: AudioRecorder())
    }
}
