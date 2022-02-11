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
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleInterruption(notification:)),
                                                   name: NSNotification.Name.AVAudioSessionInterruption,
                                                   object: theSession)
            
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
        audioEngine?.pause()
        audioEngine?.inputNode.removeTap(onBus: 0)
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
    
    func handleInterruption(notification: NSNotification) {
        print("handleInterruption")
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSessionInterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey])
                return }
        switch interruptionType {
        case .began:
            print("began")
            vox.pause()
            music.pause()
            print("audioPlayer.playing", vox.isPlaying)
            /**/
            do {
                try theSession.setActive(false)
                print("AVAudioSession is inactive")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            pause()
        default :
            print("ended")
            if let optionValue = (notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber)?.uintValue, AVAudioSessionInterruptionOptions(rawValue: optionValue) == .shouldResume {
                print("should resume")
                // ok to resume playing, re activate session and resume playing
                /**/
                do {
                    try theSession.setActive(true)
                    print("AVAudioSession is Active again")
                    vox.play()
                    music.play()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                play()
            }
        }
    }
}

