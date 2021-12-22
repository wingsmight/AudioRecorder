//
//  SettingsTab.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import SwiftyStoreKit

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

struct SectionButton : View {
    private var key : String
    private var value : String
    private var action : () -> Void
    
    
    init(key: String, value: String, action: @escaping () -> Void) {
        self.key = key
        self.value = value
        self.action = action
    }
    
    
    var body: some View {
        Button (action: action, label: {
            HStack {
                Text(key)
                Spacer()
                Text(value)
                    .accentColor(.secondary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Image(systemName: "chevron.forward")
                    .accentColor(.secondary)
            }
            .accentColor(Color(UIColor.label))
        })
    }
}

struct SettingsTab: View {
    @Binding var colorScheme : AppColorScheme
    
    @State private var isToggleOn : Bool = false
    @State private var isAppInfoShowing = false
    @State private var isCloudStorageChoiceShowing = false
    @State private var isDoNotDisturbIntervalViewShowing = false
    @State private var isSignOutConfirmationShowing = false
    @State private var storedSize: Int = 0
    @State private var user: User = User()
    
    @EnvironmentObject var appAuth: AppAuth
    
    @AppStorage("user") var userData: Data = Data()
    @AppStorage("doNotDisturbStartTime") private var doNotDisturbStartTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
    @AppStorage("doNotDisturbFinishTime") private var doNotDisturbFinishTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @AppStorage("isTurnOnByVoice") private var isTurnOnByVoice = true
    @AppStorage("availableStorageSize") private var availableStorageSize: Int = CloudDatabase.Plan.free200MB.size
    @AppStorage("usedStorageSize") private var usedStorageSize: Int = 0
    @AppStorage("storageFillPercent") private var storageFillPercent: Double = 0.0
    
    var body: some View {
        Form {
            Section(header: Text("Профиль")) {
                HStack {
                    Spacer()
                    Text(user.name + " " + user.surname)
                        .bold()
                        .font(.title2)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                    Spacer()
                }
                TextInfo(key: "Дата рождения", value: user.birthDate.toString(dataStyle: .short))
                TextInfo(key: "Почта", value: user.email)
                TextInfo(key: "Телефон", value: user.phoneNumber)
                Button {
                    isSignOutConfirmationShowing = true
                } label: {
                    Text("Выйти из аккаунта")
                        .foregroundColor(.red)
                }
                .alert(isPresented: $isSignOutConfirmationShowing) {
                    Alert(title: Text("Выйти из аккаунта"), message: Text("Вы уверены?"),
                          primaryButton: .default(Text("Нет"), action: {
                        
                    }),
                          secondaryButton: .destructive(Text("Да"), action: {
                            appAuth.signOut()
                    })
                    )
                }
            }
            Section(header: Text("Опции")) {
                SectionButton(key: "Не записывать в", value: "\(doNotDisturbStartTime.getTimeString()) - \(doNotDisturbFinishTime.getTimeString())") {
                    isDoNotDisturbIntervalViewShowing = true
                }
                Toggle(isOn: $isTurnOnByVoice) {
                    Text("Включение записи по голосу")
                }
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
                ZStack {
                    StorageBar(value: $storageFillPercent)
                    HStack {
                        Text(convertToHumanFileSize(bytes: self.usedStorageSize))
                            .padding(.leading)
                        Spacer()
                        Text(convertToHumanFileSize(bytes: self.availableStorageSize))
                            .padding(.trailing)
                    }
                }
                SectionButton(key: "Размер облака", value: convertToHumanFileSize(bytes: self.availableStorageSize)) {
                    self.isCloudStorageChoiceShowing = true
                }
            }
            Section(header: Text("Справка")) {
                Button {
                    isAppInfoShowing.toggle()
                } label: {
                    Text("О принципах работы приложения")
                }
            }
            Section(header: Text("Контакты")) {
                Text("...")
                    .foregroundColor(.secondary)
            }
            Section(header: Text("Другое")) {
                Button {
                    SwiftyStoreKit.purchaseProduct(Store.products["SupportDeveloper"]!, quantity: 1, atomically: true) { result in
                        switch result {
                        case .success(let purchase):
                            print("Purchase Success: \(purchase.productId)")
                        case .error(let error):
                            switch error.code {
                            case .unknown: print("Unknown error. Please contact support")
                            case .clientInvalid: print("Not allowed to make the payment")
                            case .paymentCancelled: break
                            case .paymentInvalid: print("The purchase identifier was invalid")
                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                            default: print((error as NSError))
                            }
                        }
                    }
                } label: {
                    Text("Поблагодарить разработчика")
                }
            }
        }
        .onAppear() {
            user = User.load()
        }
        .onDisappear() {
            User.save(self.user)
        }
        .onChange(of: userData, perform: { newUserData in
            user = User.load()
        })
        .sheet(isPresented: $isAppInfoShowing) {
            AppInfoView(isShowing: self.$isAppInfoShowing)
        }
        .sheet(isPresented: $isCloudStorageChoiceShowing) {
            CloudStorageChoiceView(isShowing: self.$isCloudStorageChoiceShowing)
        }
        .sheet(isPresented: $isDoNotDisturbIntervalViewShowing) {
            TimeIntervalPickerView(startTime: $doNotDisturbStartTime, finishTime: $doNotDisturbFinishTime, isShowing: $isDoNotDisturbIntervalViewShowing)
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

func convertToHumanFileSize(bytes: Int, systemInternational: Bool = true) -> String {
    let thresh = systemInternational ? 1000 : 1024
    var bytes: Int = bytes

    if (abs(bytes) < thresh) {
        return "\(bytes) B"
    }

    let units = systemInternational
        ? ["kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        : ["KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"]
    var u = -1

    repeat {
        bytes /= thresh
        u += 1
    } while (abs(bytes) >= thresh && u < units.count - 1);


    return "\(bytes) \(units[u])"
}
