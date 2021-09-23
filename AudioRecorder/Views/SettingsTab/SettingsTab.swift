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
    @State private var isToggleOn : Bool = false
    @State private var selectedStrength = "Mild"
    @Binding var colorScheme : AppColorScheme
    @State private var user = User(photoLocation: "", name: "name", surname: "surname", birthDate: Date(), email: "email", phoneNumber: "+79134807883", facebookProfileUrl: "")
    @State private var isAppInfoShowing = false
    @State private var isCloudStorageChoiceShowing = false
    
    
    var body: some View {
        Form {
            Section(header: Text("Профиль")) {
                HStack {
                    Image(systemName: user.photoLocation == "" ? "person.crop.circle" : user.photoLocation)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100, alignment: Alignment.center)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(user.name + " " + user.surname)
                            .bold()
                            .font(.title2)
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                    }
                }
                TextInfo(key: "Дата рождения", value: user.birthDate.ToString())
                TextInfo(key: "Почта", value: user.email)
                TextInfo(key: "Телефон", value: user.phoneNumber)
                Link("Профиль Facebook", destination: URL(string: "https://facebook.com")!)
            }
            Section(header: Text("Внешний вид")) {
                Picker("Главная тема", selection: $colorScheme) {
                    ForEach(AppColorScheme.allCases, id: \.self) { value in
                        Text(value.localizedName)
                    }
                }
                .onChange(of: colorScheme) { newValue in
                    Theme.colorScheme = newValue
                    colorScheme = newValue
                }
            }
            Section(header: Text("Облако")) {
                Button {
                    
                } label: {
                    Text("Проверить состояние облака")
                }
                Button {
                    self.isCloudStorageChoiceShowing = true
                } label: {
                    HStack {
                        Text("Размер облака")
                        Spacer()
                        Text("200 MB")
                            .accentColor(.secondary)
                        Image(systemName: "chevron.forward")
                            .accentColor(.secondary)
                    }
                    .accentColor(Color(UIColor.label))
                }
            }
            Section(header: Text("Справка")) {
                Button {
                    isAppInfoShowing.toggle()
                } label: {
                    Text("О принципах работы приложения")
                }
                
            }
        }
        .sheet(isPresented: $isAppInfoShowing) {
            AppInfoView(isShowing: self.$isAppInfoShowing)
        }
        .sheet(isPresented: $isCloudStorageChoiceShowing) {
            CloudStorageChoiceView(isShowing: self.$isCloudStorageChoiceShowing)
        }
        .navigationTitle("Настройки")
        .padding(.top, 1)
        .sheet(isPresented: $isAppInfoShowing) {
            AppInfoView(isShowing: self.$isAppInfoShowing)
        }
    }
}

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab(colorScheme: .constant(AppColorScheme.System))
    }
}
