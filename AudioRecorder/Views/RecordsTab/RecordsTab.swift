//
//  RecordsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import AVKit

struct RecordsTab: View {
    @ObservedObject var audioRecorder: AudioRecorder
    
    @State private var audioPlayer: AVAudioPlayer! // = try AVAudioPlayer(contentsOf: audioRecord.fileURL)
    
    var body: some View {
        List {
            Button {
                delete(at: IndexSet(0...(audioRecorder.recordings.count - 1)))
            } label: {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(Color(UIColor.red))
            }
            .disabled(audioRecorder.recordings.count <= 0)
            
            ForEach(audioRecorder.recordings, id: \.createdAt) { recording in
                RecordView(audioRecord: AudioRecord(fileURL: recording.fileURL, createdAt: recording.createdAt), audioPlayer: self.$audioPlayer)
            }
            .onDelete(perform: delete)
        }
        .onChange(of: audioRecorder.recordings, perform: { newValue in
            print("new value = \(newValue.count)")
        })
        .navigationTitle("Аудиозаписи")
        .padding(.top, 1)
    }
    
    private func delete(withURL url: URL) {
        var urlsToDelete = [URL]()
        urlsToDelete.append(url)
        audioRecorder.deleteRecordings(urlsToDelete: urlsToDelete)
    }
    private func delete(at offsets: IndexSet) {
        var urlsToDelete = [URL]()
        for index in offsets {
            urlsToDelete.append(audioRecorder.recordings[index].fileURL)
        }
        audioRecorder.deleteRecordings(urlsToDelete: urlsToDelete)
    }
}


struct RecordsTab_Previews: PreviewProvider {
    static var previews: some View {
        RecordsTab(audioRecorder: AudioRecorder())
    }
}
