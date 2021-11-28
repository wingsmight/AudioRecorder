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
import CoreLocation

struct RecordView: View {
    public var audioRecord: AudioRecord
    @Binding public var expandedRecord: String
    @Binding public var audioPlayer: AVAudioPlayer!
    
    @State private var sliderValue: Float = 0.0
    @State private var isSliderEditing: Bool = false
    @State private var isPlaying: Bool = false
    @State private var location: CLPlacemark?
    
    @State var scrubState: PlayerScrubState = .reset {
            didSet {
                switch scrubState {
                case .reset:
                    return
                case .scrubStarted:
                    return
                case .scrubEnded(let seekTime):
                    self.audioPlayer.currentTime = TimeInterval((Double(sliderValue) / 100.0) * self.audioPlayer.duration)
                    if !self.audioPlayer.isPlaying {
                        audioPlayer.play()
                    }
                    self.isPlaying = self.audioPlayer.isPlaying
                    
                    return
                }
            }
        }

    private var isExpanded: Bool {
        set { expandedRecord = newValue ? audioRecord.fileURL.path : "" }
        get { return expandedRecord == audioRecord.fileURL.path }
    }
    
    var body: some View {
        VStack {
            Button {
                expandedRecord = isExpanded ? "" : audioRecord.fileURL.path
                
                if isExpanded {
                    // TODO: process ERROR!
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: audioRecord.fileURL)
                    } catch {
                        print(audioRecord.fileURL.path)
                        print("RecordView error = \(error)")
                    }
                    
                    if location == nil {
                        audioRecord.lookUpCurrentLocation { placemark in
                            location = placemark
                        }
                    }
                }
                
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
                Slider(value: $sliderValue, in: 0.0...100.0) { isScrubStarted in
                    if isScrubStarted {
                         self.scrubState = .scrubStarted
                      } else {
                         self.scrubState = .scrubEnded(self.audioPlayer.currentTime)
                      }
                    
                    isSliderEditing = isScrubStarted
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
                        
                        // backward button
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
                        
                        // play/pause button
                        Button {
                            if (self.audioPlayer != nil) {
                                if self.audioPlayer.isPlaying {
                                    audioPlayer.pause()
                                } else {
                                    audioPlayer.play()
                                }
                                
                                self.isPlaying = self.audioPlayer.isPlaying
                            }
                        } label: {
                            Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding()
                        }
                        
                        // forward button
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
                    
                    // share button
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
                .padding(.top, 4)
                
                HStack {
                    Text("Геопозиция: ")
                    
                    Spacer()
                    
                    if let certainLocation = location {
                        Text(certainLocation.name ?? "не определено")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("не определено")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .onChange(of: expandedRecord) { newValue in
            // if new record is playing
            if newValue != audioRecord.fileURL.path {
                self.audioPlayer.stop()
                self.isPlaying = false
            }
        }
        .onAppear() {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                if self.audioPlayer != nil && !isSliderEditing {
                    updateSlider()
                }
            }
        }
    }
    
    func updateSlider() {
        self.sliderValue = Float(self.audioPlayer.currentTime / self.audioPlayer.duration) * 100.0

        if !audioPlayer.isPlaying && 100.0 - self.sliderValue < 1.0 {
            self.sliderValue = 0.0
        }

        self.isPlaying = self.audioPlayer.isPlaying
    }
    func reset() {
        self.sliderValue = 0.0
        self.audioPlayer?.stop()
        self.isPlaying = false
    }
}

struct RecorderView_Previews: PreviewProvider {
    private static let testFilePath = "file:///private/var/mobile/Containers/Data/Application/DA11F2D2-0ADC-4F26-9ADD-1A93665807FE/Documents/03-10-21_at_4:54:22%20AM.m4a"
    
    static var previews: some View {
        VStack {
            List(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
                RecordView(audioRecord: AudioRecord(fileURL: URL(fileURLWithPath: testFilePath), createdAt: Date(), location: CLLocation(latitude: 0, longitude: 0)), expandedRecord: .constant(""), audioPlayer: .constant(try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: testFilePath))))
            }
        }
    }
}
