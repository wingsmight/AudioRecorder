//
//  UIApplicationExt.swift
//  AudioRecorder
//
//  Created by Igoryok on 08.10.2021.
//

import Foundation
import UIKit


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
