//
//  SettingsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI

struct TextInfo : View {
    private var key : String
    private var value : String
    
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    
    var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
        }
    }
}
struct SettingsTab: View {
    @State var isToggleOn : Bool = false
    @State private var selectedStrength = "Mild"
    @Binding var colorScheme : AppColorScheme
    @State var user = User(photoLocation: "", name: "name", surname: "surname", birthDate: Date(), email: "email", phoneNumber: "+79134807883", facebookProfileUrl: "")
    
    let strengths = ["Mild", "Medium", "Mature"]
    
    
    var body: some View {
        Form {
            Section(header: Text("Профиль")) {
                HStack {
                    Spacer()
                    Image(systemName: user.photoLocation == "" ? "person.crop.circle" : user.photoLocation)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100, alignment: Alignment.center)
                    Spacer()
                }
                TextInfo(key: "Имя", value: user.name)
                TextInfo(key: "Фамилия", value: user.surname)
                TextInfo(key: "Дата рождения", value: user.birthDate.ToString())
                TextInfo(key: "Почта", value: user.email)
                TextInfo(key: "Телефон", value: user.phoneNumber)
                Link("Профиль Facebook", destination: URL(string: "https://facebook.com")!)
            }
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
