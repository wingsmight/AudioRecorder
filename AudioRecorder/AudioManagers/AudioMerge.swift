//
//  AudioMerge.swift
//  AudioRecorder
//
//  Created by Igoryok on 27.10.2021.
//

import Foundation
import AVKit
import AVFAudio
import AVFoundation


func mergeAudioFiles(audioFileUrls: NSArray, mergeAudioURL: URL) {
    let composition = AVMutableComposition()

    for i in 0 ..< audioFileUrls.count {
        let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!

        let asset = AVURLAsset(url: (audioFileUrls[i] as! NSURL) as URL)

        let track = asset.tracks(withMediaType: AVMediaType.audio)[0]

        let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale: 600), duration: track.timeRange.duration)

        try! compositionAudioTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
    }

    let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
    assetExport?.outputFileType = AVFileType.m4a
    assetExport?.outputURL = mergeAudioURL
    assetExport?.exportAsynchronously(completionHandler:
        {
            switch assetExport!.status
            {
            case AVAssetExportSession.Status.failed:
                print("failed \(String(describing: assetExport?.error))")
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(String(describing: assetExport?.error))")
            case AVAssetExportSession.Status.unknown:
                print("unknown\(String(describing: assetExport?.error))")
            case AVAssetExportSession.Status.waiting:
                print("waiting\(String(describing: assetExport?.error))")
            case AVAssetExportSession.Status.exporting:
                print("exporting\(String(describing: assetExport?.error))")
            default:
                print("Audio Concatenation Complete")
            }
    })
}
