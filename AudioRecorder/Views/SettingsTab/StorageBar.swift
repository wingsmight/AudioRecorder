//
//  StorageBar.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.12.2021.
//

import SwiftUI

struct StorageBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemFill))
                
                Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemGray))
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}

struct StorageBar_Previews: PreviewProvider {
    static var previews: some View {
        StorageBar(value: .constant(0.75))
    }
}
