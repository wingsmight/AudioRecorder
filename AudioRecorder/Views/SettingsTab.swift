//
//  SettingsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI

struct SettingsTab: View {
    @State var isToggleOn : Bool = false
    @State private var selectedStrength = "Mild"
    @Binding var colorScheme : AppColorScheme
    let strengths = ["Mild", "Medium", "Mature"]
    
    
    var body: some View {
        Form {
            Section(header: Text("Внешний вид")) {
                Picker("Главная тема", selection: self.$colorScheme) {
                    ForEach(AppColorScheme.allCases, id: \.self) { value in
                        Text(value.localizedName)
                    }
                }
            }
        }
        .navigationTitle("Настройки")
        .padding(.top, 1)
    }
}

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab(colorScheme: .constant(AppColorScheme.System))
    }
}
