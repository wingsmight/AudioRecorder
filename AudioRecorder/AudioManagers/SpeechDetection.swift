//
//  ViewController.swift
//  VoskApiTest
//
//  Created by Niсkolay Shmyrev on 01.03.20.
//  Copyright © 2020-2021 Alpha Cephei. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechDetection {
    var audioEngine : AVAudioEngine!
    var processingQueue: DispatchQueue!
    var model : VoskModel!
    
    
    init() {
        processingQueue = DispatchQueue(label: "recognizerQueue")
        model = VoskModel()
    }
    
    
    func startAudioEngine(onDetected: @escaping (String) -> Void) {
        do {
            // Create a new audio engine.
            audioEngine = AVAudioEngine()
            
            let inputNode = audioEngine.inputNode
            let formatInput = inputNode.inputFormat(forBus: 0)
            let formatPcm = AVAudioFormat.init(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: formatInput.sampleRate, channels: 1, interleaved: true)
            
            let recognizer = Vosk(model: model, sampleRate: Float(formatInput.sampleRate))
            
            inputNode.installTap(onBus: 0,
                                 bufferSize: UInt32(formatInput.sampleRate / 10),
                                 format: formatPcm) { buffer, time in
                                    self.processingQueue.async {
                                        let res = recognizer.recognizeData(buffer: buffer)
                                        DispatchQueue.main.async {
                                            let result = self.getText(fromResult: res)
                                            if !result.isEmpty || !UserDefaults.standard.bool(forKey: "isTurnOnByVoice") {
                                                print("speech was detected: \(result)")
                                                onDetected(result)
                                            }
                                        }
                                    }
            }
            
            // Start the stream of audio data.
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
    func stopAudioEngine() {
        audioEngine?.stop()
    }
    
    func runRecognizeFile(fileURL: URL) {
        processingQueue.async {
            let recognizer = Vosk(model: self.model, sampleRate: 16000.0)
            let res = recognizer.recognizeFile(file: fileURL)
            DispatchQueue.main.async {
                //self.mainText.text = res
            }
        }
    }
    
    private func getText(fromResult rawResult: String) -> String {
        do {
            let result = rawResult.slice(from: "\"partial\" : \"", to: "\"\n}")
            
            return result != nil ? result! : ""
        } catch {
            return ""
        }
    }
}

