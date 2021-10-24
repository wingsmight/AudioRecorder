//
//  RecordAssembly.swift
//  AudioRecorder
//
//  Created by Igoryok on 23.10.2021.
//

import Foundation

public class RecordAssembly {
    static func Process(audioRecorder: AudioRecorder) {
        let audioURLs = AudioRecorder.rawRecordingUrls
        print("raw recordings count = \(audioURLs.count)")
        print("SpeechRecogniser.START")

        processNext(audioRecorder: audioRecorder)
    }
    
    static func processNext(audioRecorder: AudioRecorder) {
        if (AudioRecorder.rawRecordingUrls.count <= 0) {
            return
        }
        
        let audioURL = AudioRecorder.rawRecordingUrls.first;
        SpeechRecogniser.hasSpeech(audioURL: audioURL!) { hasSpeech in
            print("\(String(describing: audioURL)) has speech - \(hasSpeech)")
            
            if !hasSpeech {
                audioRecorder.deleteRecording(url: audioURL!)
            }
            
            AudioRecorder.rawRecordingUrls.removeFirst()
            
            audioRecorder.fetchRecordings()
            
            processNext(audioRecorder: audioRecorder)
        }
    }
}
