//
//  RecordsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI

struct RecordsTab: View {
    @State var audios : [String] = []
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(audios, id: \.self) { audio in
                    Text(audio)
                        .lineLimit(nil)
                        .padding(7)
                }
                
                Text("Title 0")
                    .lineLimit(nil)
                    .padding(7)
                Text("Title 1")
                    .lineLimit(nil)
                    .padding(7)
                Spacer()
            }
        }
        .navigationTitle("Аудиозаписи")
        .padding(.top, 1)
        .onAppear() {
            getAudios();
        }
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

struct RecordsTab_Previews: PreviewProvider {
    static var previews: some View {
        RecordsTab()
    }
}
