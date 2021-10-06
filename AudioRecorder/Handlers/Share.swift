//
//  Share.swift
//  AudioRecorder
//
//  Created by Igoryok on 06.10.2021.
//

import Foundation
import AVKit


@discardableResult func share(items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) -> Bool {
    guard let source = UIApplication.shared.windows.last?.rootViewController else {
        return false
    }
    let vc = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil
    )
    vc.excludedActivityTypes = excludedActivityTypes
    vc.popoverPresentationController?.sourceView = source.view
    source.present(vc, animated: true)
    return true
}
