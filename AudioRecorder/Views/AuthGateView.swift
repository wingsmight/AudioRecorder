//
//  AuthGateView.swift
//  AudioRecorder
//
//  Created by Igoryok on 08.10.2021.
//

import SwiftUI

struct AuthGateView: View {
    @EnvironmentObject var appAuth: AppAuth
    
    
    var body: some View {
        if appAuth.signedIn {
            ContentView()
                .onAppear {
                    appAuth.signedIn = appAuth.isSignedIn
                }
        } else {
            LogInView()
                .onAppear {
                    appAuth.signedIn = appAuth.isSignedIn
                }
        }
    }
}

struct AuthGateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthGateView()
    }
}
