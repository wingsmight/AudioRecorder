//
//  RecordAssembly.swift
//  AudioRecorder
//
//  Created by Igoryok on 23.10.2021.
//

import Foundation
import AVFoundation

public class RecordAssembly {
    static let maxRecordDurationSeconds: Double = 5 * 60 // 5 mins
    
    static var isProcessing = false
    
    
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
        
        var audioURL: URL! = AudioRecorder.rawRecordingUrls.first;
        SpeechRecogniser.hasSpeech(audioURL: audioURL) { hasSpeech in
            print(222)
            isProcessing = false
            print("\(String(describing: audioURL)) has speech - \(hasSpeech)")
            
            AudioRecorder.rawRecordingUrls.removeFirst()
            
            if !hasSpeech {
                audioRecorder.deleteRecording(url: audioURL!)
            }
            processNext(audioRecorder: audioRecorder)
        }
    }
}
            
//            let secondAudioURL: URL! = AudioRecorder.rawRecordingUrls.first
//            // check for speech 2nd 10 sec audio span
//            SpeechRecogniser.hasSpeech(audioURL: secondAudioURL) { hasSpeech in
//                isProcessing = false
//                print("\(String(describing: secondAudioURL)) has speech - \(hasSpeech)")
//
//                if !hasSpeech {
//                    audioRecorder.deleteRecording(url: secondAudioURL)
//
//                    AudioRecorder.rawRecordingUrls.removeFirst()
//                    processNext(audioRecorder: audioRecorder)
//
//                    return
//                } else {
//                    mergeAudioFiles(audioFileUrls: [audioURL, secondAudioURL], mergeAudioURL: audioURL)
//                    AudioRecorder.rawRecordingUrls.removeFirst()
//
//                    let overallDuration = getDuration(for: audioURL)
//                    if overallDuration >= maxRecordDurationSeconds {
//                        //cut and start process next record from its 0 sec
//                        processNext(audioRecorder: audioRecorder)
//                        return
//                    }
//                }
//            }
//            isProcessing = true;


//            //Trimming
//            let outputAudioUrl: URL! = FileManager.getDocumentsDirectory().appendingPathComponent("outputAudioUrl")
//            AudioTrim.trimSound(inUrl: audioURL, outUrl: outputAudioUrl, timeRange: CMTimeRange(start: CMTime(0), duration: CMTime(minSilenceSeconds))) {
//                AudioRecorder.rawRecordingUrls.insert(outputAudioUrl, at: 0)
//                processNext(audioRecorder: audioRecorder, timeRange: CMTimeRange(start: CMTime(0), duration: CMTime(minSilenceSeconds)))
//            }
//
//            // Thread v2.0
//            // Trim 1st 10 secs of recording
////            if speech {
////                trim from 10 to 20 sec
////                if !speech
////
////            } else {
////                remove 1st 10 secs from whole recording
////            }
