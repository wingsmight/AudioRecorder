//
//  AudioHandler.swift
//  AudioRecorder
//
//  Created by Igoryok on 27.10.2021.
//

import Foundation
import AVKit

public func getDuration(for url: URL) -> Double {
    let audioAsset = AVAsset(url: url)
    return Double(CMTimeGetSeconds(audioAsset.duration))
}
