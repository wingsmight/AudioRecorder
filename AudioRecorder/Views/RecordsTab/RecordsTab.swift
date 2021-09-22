//
//  RecordsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI

struct RecordsTab: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
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
    }
}

struct RecordsTab_Previews: PreviewProvider {
    static var previews: some View {
        RecordsTab()
    }
}
