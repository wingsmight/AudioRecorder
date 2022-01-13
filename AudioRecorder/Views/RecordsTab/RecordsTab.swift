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
    @State private var selection = Set<AudioRecord>()
    @State private var editMode = EditMode.inactive
    

    var body: some View {
        List(selection: $selection) {
            ForEach(recordings, id: \.self) { recording in
                RecordView(audioRecord: AudioRecord(fileURL: recording.fileURL, createdAt: recording.createdAt, location: recording.location), expandedRecord: $expandedChildName, audioPlayer: self.$audioPlayer)
            }
            .onDelete(perform: tryDelete)
        }
        .navigationTitle("Аудиозаписи")
        .padding(.top, 1)
        .navigationBarItems(leading: DeleteButton, trailing: EditButton())
        .environment(\.editMode, self.$editMode)
    }
    
    private func delete(withURL url: URL) {
        if audioPlayer != nil && audioPlayer.url == url {
            audioPlayer.stop()
        }
        AudioRecorder.deleteRecording(url: url)
    }
    private func tryDelete(at offsets: IndexSet) {
        Biometrics.isAvailable(reason: "Face ID требуется для определения, что именно вы хотите удалить запись.") { success in
            if success {
                delete(at: offsets)
            }
        }
    }
    private func delete(at offsets: IndexSet) {
        var urlsToDelete = [URL]()
        for index in offsets {
            urlsToDelete.append(recordings[index].fileURL)
        }
        recordings.remove(atOffsets: offsets)
        for urlToDelete in urlsToDelete {
            delete(withURL: urlToDelete)
        }
    }
    private func deleteSelection() {
        var selectedSet = IndexSet()
        for selectedRecord in selection {
            if let index = recordings.lastIndex(where: { $0 == selectedRecord })  {
                selectedSet.insert(index)
            }
        }
        selection = Set<AudioRecord>()
        
        tryDelete(at: selectedSet)
    }
    
    
    private var DeleteButton: some View {
        if editMode == .inactive || selection.count <= 0 {
            return Button(action: {}) {
                Image(systemName: "")
            }
        } else {
            return Button(action: deleteSelection) {
                Image(systemName: "trash")
            }
        }
    }
}


struct RecordsTab_Previews: PreviewProvider {
    static var previews: some View {
        RecordsTab()
    }
}
