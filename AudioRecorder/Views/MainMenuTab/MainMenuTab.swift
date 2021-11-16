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


struct MainMenuTab: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var isRecordingToastShowing = false
    @State private var playTapEngine: CHHapticEngine?
    @State private var transcript = ""
    @State private var isRecording = false
    
    private var speechDetection = SpeechDetection()
    
    
    var body: some View {
        VStack {
            ZStack {
                if audioRecorder.recording {
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
                    isRecording.toggle()
                    isRecordingToastShowing = isRecording
                    
                    if !isRecording {
                        audioRecorder.stopRecording()
                        
                        speechDetection.stopAudioEngine()
                    } else {
                        speechDetection.startAudioEngine { recognizedText in
                            if !audioRecorder.recording {
                                audioRecorder.startRecording()
                            } else {
                                audioRecorder.resetAutoStop()
                            }
                        }
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
            }
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
}

struct MainMenuTab_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuTab()
    }
}
