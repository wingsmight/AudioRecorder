//
//  RecordsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import AVKit

struct RecordsTab: View {
    @State var audios : [String] = []
    
    @ObservedObject var audioRecorder: AudioRecorder
    
    var body: some View {
        List {
            ForEach(audioRecorder.recordings, id: \.createdAt) { recording in
                RecordingRow(audioURL: recording.fileURL)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Аудиозаписи")
        .padding(.top, 1)
        .onAppear() {
            getAudios();
        }
    }
    
    private func delete(at offsets: IndexSet) {
        
        var urlsToDelete = [URL]()
        for index in offsets {
            urlsToDelete.append(audioRecorder.recordings[index].fileURL)
        }
        audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
    }
    private func getAudios() {
        do {
            let filesDictionaryURL = FileManager.getDocumentsDirectory().appendingPathComponent("AudioRecords", isDirectory: true)
            let storedAudios = try FileManager.default.contentsOfDirectory(at: filesDictionaryURL, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            self.audios.removeAll()
            
            for storedAudio in storedAudios {
                self.audios.append(storedAudio.path)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

struct RecordingRow: View {
    
    var audioURL: URL
    
    @ObservedObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        HStack {
            Text("\(audioURL.lastPathComponent)")
            Spacer()
            if audioPlayer.isPlaying == false {
                Button(action: {
                    self.audioPlayer.startPlayback(audio: self.audioURL)
                }) {
                    Image(systemName: "play.circle")
                        .imageScale(.large)
                }
            } else {
                Button(action: {
                    self.audioPlayer.stopPlayback()
                }) {
                    Image(systemName: "stop.fill")
                        .imageScale(.large)
                }
            }
        }
    }
    
//    
//    func delete(at offsets: IndexSet) {
//        var urlsToDelete = [URL]()
//        for index in offsets {
//            urlsToDelete.append(audioRecorder.recordings[index].fileURL)
//        }
//        audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
//    }
}

struct RecordsTab_Previews: PreviewProvider {
    static var previews: some View {
        RecordsTab(audioRecorder: AudioRecorder())
    }
}
