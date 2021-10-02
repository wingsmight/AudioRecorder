//
//  MainMenuTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import AVKit
import CoreHaptics


struct MainMenuTab: View {
    @Binding var isRecordingToastShowing : Bool
    @StateObject var audioRecorder: AudioRecorder
    
    @State private var playTapEngine: CHHapticEngine?
    @AppStorage("recordCount") private var recordCount = 0;
    
    
    var recordingButtonImage : String {
        return self.IsRecording ? "stop.fill" : "play.fill"
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                if IsRecording {
                    Circle()
                        .fill(Color.green)
                        .shadow(radius: 3)
                        .opacity(0.333)
                        .frame(width: 110 * CGFloat(1 + 0.95 * audioRecorder.soundSamples[2]), height: (100 + (IsRecording ? 10 : 0)) * CGFloat(1 + 0.95 * audioRecorder.soundSamples[2]))
                    Circle()
                        .fill(Color.green)
                        .shadow(radius: 3)
                        .opacity(0.333)
                        .frame(width: 105 * CGFloat(1 + 0.6 * audioRecorder.soundSamples[0]), height: (100 + (IsRecording ? 5 : 0)) * CGFloat(1 + 0.6 * audioRecorder.soundSamples[0]))
                }
                
                Button(action: {
                    isRecordingToastShowing = IsRecording
                    
                    if IsRecording {
                        audioRecorder.stopRecording()
                        
                        self.recordCount += 1
                    } else {
                        audioRecorder.startRecording()
                    }
                    
                    vibrate(intensity: 0.7, sharpness: 0.7)
                }) {
                    Image(systemName: recordingButtonImage)
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
    
    var IsRecording: Bool {
        audioRecorder.recording
    }
    

    func initHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.playTapEngine = try CHHapticEngine()
            try playTapEngine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
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
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

struct MainMenuTab_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuTab(isRecordingToastShowing: .constant(false), audioRecorder: AudioRecorder())
    }
}
