//
//  SettingsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI

struct SettingsTab: View {
    @State var isToggleOn : Bool = false
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Toggle("Title 0", isOn: $isToggleOn)
                    .lineLimit(nil)
                    .padding(7)
                    .background(Color("optionBackgroundColor"))
                Divider()
                Toggle("Title 1", isOn: $isToggleOn)
                    .lineLimit(nil)
                    .padding(7)
                    .background(Color("optionBackgroundColor"))
                Spacer()
            }
        }
        .navigationTitle("Настройки")
        .padding(.top, 1)
    }
}

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
    }
}
