//
//  RecordsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import AVKit

struct RecordsTab: View {
    let location = LocationManager()
    @AppStorage("recordings") private var recordings: [AudioRecord] = []
    
    @State private var audioPlayer: AVAudioPlayer!
    @State private var expandedChildName: String = ""
    

    var body: some View {
        List {
            Button {
                location.requestLocation()
            } label: {
                Text("get location")
            }

            ForEach(recordings, id: \.createdAt) { recording in
                RecordView(audioRecord: AudioRecord(fileURL: recording.fileURL, createdAt: recording.createdAt, location: recording.location), expandedRecord: $expandedChildName, audioPlayer: self.$audioPlayer)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Аудиозаписи")
        .padding(.top, 1)
    }
    
    private func delete(withURL url: URL) {
        if audioPlayer.url == url {
            audioPlayer.stop()
        }
        AudioRecorder.deleteRecording(url: url)
    }
    private func delete(at offsets: IndexSet) {
        var urlsToDelete = [URL]()
        for index in offsets {
            urlsToDelete.append(recordings[index].fileURL)
        }
        let indexToDelete = offsets.last!
        for _ in 1...offsets.count {
            recordings.remove(at: indexToDelete)
        }
        for urlToDelete in urlsToDelete {
            delete(withURL: urlToDelete)
        }
    }
}


struct RecordsTab_Previews: PreviewProvider {
    static var previews: some View {
        RecordsTab()
    }
}
