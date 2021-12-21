//
//  MainMenuTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import AVKit
import CoreHaptics
import Speech
import LocalAuthentication


struct MainMenuTab: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var isRecordingToastShowing = false
    @State private var playTapEngine: CHHapticEngine?
    @State private var transcript = ""
    @State private var isRecording = false
    @StateObject private var stopwatch = Stopwatch()
    
    private var speechDetection = SpeechDetection()
    
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            ZStack {
                if audioRecorder.isRecording && isRecording {
                    Circle()
                        .fill(Color.green)
                        .shadow(radius: 3)
                        .opacity(0.333)
                        .frame(width: 110 * CGFloat(1 + 0.95 * audioRecorder.soundSamples[2]), height: (100 + (isRecording ? 10 : 0)) * CGFloat(1 + 0.95 * audioRecorder.soundSamples[2]))
                    Circle()
                        .fill(Color.green)
                        .shadow(radius: 3)
                        .opacity(0.333)
                        .frame(width: 105 * CGFloat(1 + 0.6 * audioRecorder.soundSamples[0]), height: (100 + (isRecording ? 5 : 0)) * CGFloat(1 + 0.6 * audioRecorder.soundSamples[0]))
                }
                
                Button(action: {
                    if isRecording {
                        isStopAvailable {isSucceed in
                            if isSucceed {
                                audioRecorder.stopRecording()
                                speechDetection.stopAudioEngine()
                                stopwatch.pause()
                                
                                isRecording = false
                                isRecordingToastShowing = isRecording
                            }
                        }
                    } else {
                        speechDetection.startAudioEngine { recognizedText in
                            if !audioRecorder.isRecording {
                                audioRecorder.startRecording()
                                stopwatch.reset()
                            } else {
                                audioRecorder.resetAutoStop()
                                if stopwatch.mode != .running {
                                    stopwatch.start()
                                }
                            }
                        }
                        
                        isRecording = true
                        isRecordingToastShowing = isRecording
                    }
                    
                    vibrate(intensity: 0.7, sharpness: 0.7)
                }) {
                    Image(systemName: self.isRecording ? "stop.fill" : "play.fill")
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        .font(.system(size: 50))
                        .clipShape(Circle())
                }
                .shadow(radius: 10)
                .onLongPressGesture(minimumDuration: 2.5, maximumDistance: .infinity, pressing: { pressing in
                    if pressing {
                        vibrate(intensity: 0.7, sharpness: 0.1)
                    }
                }, perform: { })
                
                VStack {
                    Spacer()
                    Spacer()
                    if audioRecorder.isRecording && isRecording {
                        TimeView(time: stopwatch.elapsedTime, textColor: .secondary, fontSize: 60, fontWeight: .thin)
                            .frame(height: 80)
                    }
                    Spacer()
                }
            }
            Spacer()
        }
        .onAppear(perform: {
            initHaptics()
        })
        .navigationTitle("Аудиорегистратор")
    }
    

    func initHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.playTapEngine = try CHHapticEngine()
            try playTapEngine?.start()
        } catch {
            print("There was an error creating the engine: \(error)")
        }
    }
    func vibrate(intensity intensityValue: Float, sharpness sharpnessValue: Float) {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensityValue)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpnessValue)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try playTapEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error).")
        }
    }
    func isStopAvailable(onPerform: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "Face ID требуется для определения, что именно вы хотите остановить запись, иначе на ваш аккаунт Facebook будет отправлено защищенное сообщение о взломе."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                if let authenticationError = authenticationError {
                    let laError = authenticationError as! LAError
                    if laError.code == LAError.Code.userFallback {
                        print("laError.code = \(laError.code)")
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                            print("0onPerform = \(success)")
                            onPerform(success)
                        }
                    } else {
                        print("1onPerform = \(success)")
                        onPerform(success)
                    }
                } else {
                    print("2onPerform = \(success)")
                    onPerform(success)
                }
            }
        } else {
            // no biometrics
            if error != nil {
                print("No biometrics = \(error)")
                let laError = error as! LAError
                print("laError.code = \(laError.code)")
                if laError.code == LAError.Code.touchIDLockout {
                    print("3onPerform = \(false)")
                    onPerform(false)
                    
                    print("WARNING. Phone has been hacking!")
                    return
                }
            }
            print("4onPerform = \(true)")
            onPerform(true)
        }
    }
}

struct MainMenuTab_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuTab()
    }
}
