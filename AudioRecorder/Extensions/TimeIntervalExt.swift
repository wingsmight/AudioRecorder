//
//  TimeIntervalExt.swift
//  AudioRecorder
//
//  Created by Igoryok on 05.10.2021.
//

import Foundation

extension TimeInterval {
    func toShortHoursMinitesFormat() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self / 1000)
    }
    func toShortMinitesSecondsFormat() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self)
    }
}
