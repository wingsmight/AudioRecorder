//
//  AudioTrim.swift
//  AudioRecorder
//
//  Created by Igoryok on 27.10.2021.
//

import Foundation
import AVKit
import AVFAudio
import AVFoundation


public class AudioTrim {
    static func trimSound(inUrl: URL, outUrl: URL, timeRange: CMTimeRange, callBack: @escaping () -> Void) {
        let startTime = timeRange.start
        let duration = timeRange.duration
        let audioAsset = AVAsset(url: inUrl)
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        
        let sourceAudioTrack = audioAsset.tracks(withMediaType: AVMediaType.audio).first!
        do {
            try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: duration), of: sourceAudioTrack, at: .zero)
            
        } catch {
            print(error.localizedDescription)
            return
        }
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        exporter!.outputURL = outUrl
        exporter!.outputFileType = AVFileType.m4a
        exporter!.shouldOptimizeForNetworkUse = true
        exporter!.exportAsynchronously {
            DispatchQueue.main.async {
                callBack()
            }
            
        }
    }
}
