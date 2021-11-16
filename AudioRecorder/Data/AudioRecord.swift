//
//  AudioRecord.swift
//  AudioRecorder
//
//  Created by Igoryok on 29.09.2021.
//

import Foundation

class AudioRecord: ObservableObject, Equatable, Identifiable {
    var id: Int
    var fileURL: URL
    var createdAt: Date
    
    init(id: Int, fileURL: URL, createdAt: Date){
        self.id = id
        self.fileURL = fileURL
        self.createdAt = createdAt
    }
    
    static func == (lhs: AudioRecord, rhs: AudioRecord) -> Bool {
        lhs.id == rhs.id
    }
}
