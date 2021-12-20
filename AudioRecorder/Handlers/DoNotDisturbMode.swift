//
//  DoNotDisturbMode.swift
//  AudioRecorder
//
//  Created by Igoryok on 21.12.2021.
//

import Foundation
import SwiftUI

class DoNotDisturbMode {
    @AppStorage("doNotDisturbStartTime") private static var doNotDisturbStartTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
    @AppStorage("doNotDisturbFinishTime") private static var doNotDisturbFinishTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    
    
    public static var isEnable: Bool {
        let now = Date();
        
        if doNotDisturbStartTime.time <= doNotDisturbFinishTime.time {
            return !now.isTimeBetweenInterval(intervalStart: doNotDisturbStartTime, intervalFinish: doNotDisturbFinishTime)
        } else {
            return now.isTimeBetweenInterval(intervalStart: doNotDisturbFinishTime, intervalFinish: doNotDisturbStartTime)
        }
    }
}
