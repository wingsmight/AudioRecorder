//
//  DisabledAppOverlayView.swift
//  AudioRecorder
//
//  Created by Igoryok on 26.09.2021.
//

import SwiftUI

struct DisabledAppOverlayView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea(.all)
                .opacity(0.1)
                .allowsHitTesting(false)
            VStack(spacing: 15) {
                Spacer()
                Text("Приложение не может работать без доступа к микрофону!")
                    .font(Font.title)
                    .bold()
                    .padding(.horizontal)
                HStack(spacing: 0) {
                    Spacer()
                    Text("Предоставьте доступ в ")
                        .font(Font.title3)
                    Button(action: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }, label: {
                        Text("настройках")
                            .font(Font.title3)
                    })
                    Spacer()
                }
                Spacer()
            }
        }
        .ignoresSafeArea(.all)
    }
}

struct DisabledAppOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        DisabledAppOverlayView()
    }
}
