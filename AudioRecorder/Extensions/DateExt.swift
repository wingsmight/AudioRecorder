//
//  DateExt.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import Foundation


extension Date {
    func ToString() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateStyle = .short

        return dateFormatterPrint.string(from: self)
    }
}
