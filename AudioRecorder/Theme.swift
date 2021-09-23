//
//  Theme.swift
//  AudioRecorder
//
//  Created by Igoryok on 23.09.2021.
//

import Foundation
import UIKit
import SwiftUI

class Theme {
    @AppStorage("colorScheme") private static var colorSchemeData : Data = Data()
    
    static var colorScheme : AppColorScheme {
        get {
            guard let colorScheme = try? JSONDecoder().decode(AppColorScheme.self, from: colorSchemeData) else { return AppColorScheme.System }
            
            return colorScheme
        }
        set {
            guard let newColorScheme = try? JSONEncoder().encode(newValue) else { return }
            
            self.colorSchemeData = newColorScheme
            
            set(appColorScheme: newValue)
        }
    }
    
    private static func set(appColorScheme: AppColorScheme) {
        if appColorScheme == AppColorScheme.System {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
            return
        }
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = appColorScheme == AppColorScheme.Dark ? .dark : .light
    }
}

public enum AppColorScheme : String, Equatable, CaseIterable, Codable {
    case Light, Dark, System
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}
