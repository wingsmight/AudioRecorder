import AVFoundation
import Foundation
import Speech
import SwiftUI

struct SpeechRecognizer {
    private class SpeechAssist {
        var audioEngine: AVAudioEngine?
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ru_RU"))

        deinit {
            reset()
        }

        func reset() {
            recognitionTask?.cancel()
            audioEngine?.stop()
            audioEngine = nil
            recognitionRequest = nil
            recognitionTask = nil
        }
        func stop() {
            recognitionTask?.finish()
            recognitionTask = nil
            
            // stop audio
            recognitionRequest?.endAudio()
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0) // Remove tap on bus when stopping recording.
        }
    }

    private let assistant = SpeechAssist()
    @State public var isRecording = false
    
    func record(to speech: Binding<String>, onRelay: @escaping (String) -> Void) {
        if (isRecording) {
            stopRecording()
        }
        
        canAccess { authorized in
            guard authorized else {
                return
            }

            assistant.audioEngine = AVAudioEngine()
            guard let audioEngine = assistant.audioEngine else {
                fatalError("Unable to create audio engine")
            }
            assistant.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = assistant.recognitionRequest else {
                fatalError("Unable to create request")
            }
            recognitionRequest.shouldReportPartialResults = true

            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .mixWithOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                let inputNode = audioEngine.inputNode

                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                    recognitionRequest.append(buffer)
                }
                audioEngine.prepare()
                try audioEngine.start()
                self.isRecording = true
                assistant.recognitionTask = assistant.speechRecognizer?.recognitionTask(with: recognitionRequest) { (result, error) in
                    var isFinal = false
                    if let result = result {
                        let message = result.bestTranscription.formattedString
                        relay(speech, message: message)
                        onRelay(message)
                        isFinal = result.isFinal
                    }

                    if error != nil || isFinal {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                            stopRecording()
                            print("recording has been stopped")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                            record(to: speech, onRelay: onRelay)
                            print("recording has been restarted")
                        }
                    }
                }
            } catch {
                print("Error transcibing audio: \(error)")
                assistant.reset()
            }
        }
    }
    func stopRecording() {
        assistant.stop()
        
        self.isRecording = false
    }
    private func canAccess(withHandler handler: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized {
                AVAudioSession.sharedInstance().requestRecordPermission { authorized in
                    handler(authorized)
                }
            } else {
                handler(false)
            }
        }
    }
    private func relay(_ binding: Binding<String>, message: String) {
        DispatchQueue.main.async {
            binding.wrappedValue = message
        }
    }
}
