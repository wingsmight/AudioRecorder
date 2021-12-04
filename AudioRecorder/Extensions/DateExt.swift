//
//  DateExt.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import Foundation


extension Date {
    func toString(dataStyle: DateFormatter.Style) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateStyle = dataStyle

        return dateFormatterPrint.string(from: self)
    }
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    func getTimeString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = .none
        dateFormatterPrint.timeStyle = .short

        return dateFormatterPrint.string(from: self)
    }
}

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}

extension Date {
    var time: Time {
        return Time(self)
    }
}

extension Date {
    func isTimeBetweenInterval(intervalStart: Date, intervalFinish: Date) -> Bool {
        return self.time >= intervalStart.time && self.time <= intervalFinish.time;
    }
}

