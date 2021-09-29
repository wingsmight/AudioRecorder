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
    
    @State private var isRecording : Bool = false
    @State var audioRecorder : AVAudioRecorder!
    
    
    @AppStorage("recordCount") private var recordCount = 0;
    
    
    var recordingButtonImage : String {
        return self.isRecording ? "stop.fill" : "play.fill"
    }
    
    
    var body: some View {
        VStack {
            Button(action: {
                do {
                    isRecording.toggle()
                    isRecordingToastShowing = isRecording
                    
                    if !isRecording {
                        audioRecorder.stop()
                        self.recordCount += 1
                    } else {
                        audioRecorder = try getAudioRecorder(fileName: "Record\(recordCount + 1).m4a")
                        audioRecorder.record()
                    }
                } catch {
                    print(error.localizedDescription)
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
    
    
    private func getAudioRecorder(fileName: String) throws -> AVAudioRecorder {
        let filesDictionaryURL = FileManager.getDocumentsDirectory().appendingPathComponent("AudioRecords", isDirectory: true)
        
        var isDirectory:ObjCBool = true
        if !FileManager.default.fileExists(atPath: filesDictionaryURL.path, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: filesDictionaryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
        let filName = filesDictionaryURL.appendingPathComponent(fileName)
        
        let settings = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 12000,
            AVNumberOfChannelsKey : 1,
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
        ]
        
        return try AVAudioRecorder(url: filName, settings: settings)
    }
}

struct MainMenuTab_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuTab(isRecordingToastShowing: .constant(false))
    }
}
