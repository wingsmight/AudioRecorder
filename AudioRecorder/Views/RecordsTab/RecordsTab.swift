//
//  RecordsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import AVKit

struct RecordsTab: View {
    @AppStorage("recordings") private var recordings: [AudioRecord] = []
    
    @State private var audioPlayer: AVAudioPlayer!
    

    var body: some View {
        List {
            ForEach(recordings, id: \.createdAt) { recording in
                RecordView(audioRecord: AudioRecord(fileURL: recording.fileURL, createdAt: recording.createdAt), audioPlayer: self.$audioPlayer)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Аудиозаписи")
        .padding(.top, 1)
    }
    
    private func delete(withURL url: URL) {
        var urlsToDelete = [URL]()
        urlsToDelete.append(url)
        AudioRecorder.deleteRecording(url: url)
    }
    private func delete(at offsets: IndexSet) {
        var urlsToDelete = [URL]()
        for index in offsets {
            urlsToDelete.append(recordings[index].fileURL)
        }
        AudioRecorder.deleteRecordings(urlsToDelete: urlsToDelete)
    }
}


struct RecordsTab_Previews: PreviewProvider {
    static var previews: some View {
        RecordsTab()
    }
}
