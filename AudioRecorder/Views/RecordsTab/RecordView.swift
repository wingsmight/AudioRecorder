//
//  RecorderView.swift
//  AudioRecorder
//
//  Created by Igoryok on 05.10.2021.
//

import SwiftUI
import AVFAudio
import AVFoundation
import AVKit

struct RecordView: View {
    var audioRecord: AudioRecord
    
    
    @State private var sliderValue: Float = 0.0
    @State private var isExpanded: Bool = false
    @State private var isSliderEditing: Bool = false
    @State private var isPlaying: Bool = false
    
    private var audioPlayer: AVAudioPlayer!
    
    
    public init(audioRecord: AudioRecord) {
        self.audioRecord = audioRecord
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioRecord.fileURL)
        } catch {
            print(error)
        }
    }
    
    
    var body: some View {
        VStack {
            Button {
                self.isExpanded.toggle()
                
                reset()
            } label: {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text("\(audioRecord.createdAt.getTimeString())")
                        .bold()
                    
                    Spacer()
                    
                    Text("\(audioRecord.createdAt.toString(dataStyle: DateFormatter.Style.short))")
                    Image(systemName: "calendar")
                        .foregroundColor(.red)
                }
            }
            .foregroundColor(.primary)
            
            if isExpanded {
                Slider(value: $sliderValue, in: 0.0...100.0) { isEditing in
                    if isEditing {
                        self.audioPlayer.currentTime = TimeInterval((Double(sliderValue) / 100.0) * self.audioPlayer.duration)
                    }
                    
                    isSliderEditing = isEditing
                }
                .accentColor(.secondary)
                
                HStack {
                    Text(self.audioPlayer.currentTime.toShortMinitesSecondsFormat() ?? "0:00")
                    Spacer()
                    Text(self.audioPlayer.duration.toShortMinitesSecondsFormat() ?? "0:00")
                }
                
                Button {
                    
                } label: {
                    HStack {
                        Spacer()
                        
                        Button {
                            audioPlayer.currentTime -= 15
                            
                            updateSlider()
                            self.isPlaying = self.audioPlayer.isPlaying
                        } label: {
                            Image(systemName: "gobackward.15")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        }
                        
                        Button {
                            if self.audioPlayer.isPlaying {
                                audioPlayer.pause()
                            } else {
                                audioPlayer.play()
                            }
                            
                            self.isPlaying = self.audioPlayer.isPlaying
                        } label: {
                            Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding()
                        }
                        
                        Button {
                            let newTime = audioPlayer.currentTime + 15
                            if newTime >= audioPlayer.duration {
                                audioPlayer.currentTime = 0.0
                                audioPlayer.stop()
                            } else {
                                audioPlayer.currentTime = newTime
                            }
                            
                            updateSlider()
                            self.isPlaying = self.audioPlayer.isPlaying
                        } label: {
                            Image(systemName: "goforward.15")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        }

                        Spacer()
                    }
                    .foregroundColor(.primary)
                }
                
                Divider()
                
                HStack {
                    Text("Размер: ")
                    Text(audioRecord.fileURL.fileSizeString)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        share(items: [audioRecord.fileURL])
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                    .foregroundColor(.blue)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 4)
            }
        }
        .onAppear() {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                if self.audioPlayer.isPlaying && !isSliderEditing {
                    updateSlider()
                }
            }
        }
    }
    
    func updateSlider() {
        self.sliderValue = Float(self.audioPlayer.currentTime / self.audioPlayer.duration) * 100.0
    }
    func reset() {
        self.sliderValue = 0.0
        self.audioPlayer.stop()
        self.isPlaying = false
    }
}

struct RecorderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            List(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
                RecordView(audioRecord: AudioRecord(fileURL: URL(fileURLWithPath: "file:///private/var/mobile/Containers/Data/Application/DA11F2D2-0ADC-4F26-9ADD-1A93665807FE/Documents/03-10-21_at_4:54:22%20AM.m4a"), createdAt: Date()))
            }
        }
    }
}
