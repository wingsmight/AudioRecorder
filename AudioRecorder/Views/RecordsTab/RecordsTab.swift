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
    
    var body: some View {
        List {
            ForEach(audioRecorder.recordings, id: \.createdAt) { recording in
                RecordView(audioRecord: AudioRecord(fileURL: recording.fileURL, createdAt: Date(), size: 10))
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Аудиозаписи")
        .padding(.top, 1)
    }
    
    private func delete(at offsets: IndexSet) {
        var urlsToDelete = [URL]()
        for index in offsets {
            urlsToDelete.append(audioRecorder.recordings[index].fileURL)
        }
        audioRecorder.deleteRecording(urlsToDelete: urlsToDelete)
    }
}


struct RecordsTab_Previews: PreviewProvider {
    static var previews: some View {
        RecordsTab(audioRecorder: AudioRecorder())
    }
}
