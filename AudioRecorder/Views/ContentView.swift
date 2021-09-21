//
//  ContentView.swift
//  AudioRecorder
//
//  Created by Igoryok on 18.09.2021.
//

import SwiftUI
import AlertToast

struct Tab {
    private let DEFAULT_ICON_SIZE : Float = 25
    private let DEFAULT_SELECT_COLOR = Color(UIColor.label)
    private let INACTIVE_COLOR = Color("inactiveTabColor")
    
    
    private var iconName : String
    private var iconSize : Float
    private var selectedColor : Color
    
    
    init(_ iconName : String) {
        self.iconName = iconName
        iconSize = DEFAULT_ICON_SIZE
        selectedColor = DEFAULT_SELECT_COLOR
    }
    init(iconName : String, iconSize : Float) {
        self.init(iconName)
        
        self.iconSize = iconSize
    }
    init(iconName : String, iconSize : Float, selectedColor : Color) {
        self.init(iconName: iconName, iconSize: iconSize)
        
        self.selectedColor = selectedColor
    }
    
    
    public var IconName : String {
        get { iconName }
    }
    public var IconSize : Float {
        get { iconSize }
    }
    public var SelectedColor : Color {
        get { selectedColor }
    }
    public var InactiveColor : Color {
        get { INACTIVE_COLOR }
    }
}

struct ContentView: View {
    @State private var selectedTabIndex = 1
    @State private var isRecordingToastShowing : Bool = false
    @State private var isRecording : Bool = false
    
    private var tabs = [
        Tab("arrow.up.left"),
        Tab(iconName: "record.circle", iconSize: 30, selectedColor: Color(UIColor.red)),
        Tab("recordingtape"),
    ]
        
    
    var body: some View {
        ZStack(alignment: Alignment.bottom) {
            TabView(selection: $selectedTabIndex) {
                SettingsTab()
                    .tabItem {
                        Text("")
                    }
                    .tag(0)
                MainMenuTab(isRecordingToastShowing: self.$isRecordingToastShowing)
                    .tabItem () {
                        Text("")
                    }
                    .tag(1)
                RecordsTab()
                    .tabItem {
                        Text("")
                    }
                    .tag(2)
            }
            .toast(isPresenting: $isRecordingToastShowing, duration: 1.25, tapToDismiss: false, offsetY: -40, alert: {
                AlertToast(displayMode: .banner(.slide), type: .regular, title: "Приложение запущено")
            })
            HStack {
                ForEach(0..<3, id: \.self) {
                                    tabIndex in
                                    
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                self.selectedTabIndex = tabIndex
                                            }, label: {
                                                let tab = tabs[tabIndex]
                                                
                                                Image(systemName: tab.IconName)
                                                    .font(.system(size: CGFloat(tab.IconSize), weight: .regular, design: .default))
                                                    .foregroundColor(selectedTabIndex == tabIndex ? tab.SelectedColor : tab.InactiveColor)
                                            })
                                            .disabled(self.selectedTabIndex == tabIndex)
                                            Spacer()
                                        }
                                        .padding(.top)
                                    }
                                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
