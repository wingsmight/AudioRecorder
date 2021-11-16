//
//  AudioRecord.swift
//  AudioRecorder
//
//  Created by Igoryok on 29.09.2021.
//

import Foundation

struct AudioRecord: Codable {
    var fileURL: URL
    var createdAt: Date
    
    init(fileURL: URL, createdAt: Date){
        self.fileURL = fileURL
        self.createdAt = createdAt
    }
}
