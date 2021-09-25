//
//  TimeIntervalPickerView.swift
//  AudioRecorder
//
//  Created by Igoryok on 25.09.2021.
//

import SwiftUI

struct TimeIntervalPickerView: View {
    @Binding var startTime: Date
    @Binding var finishTime: Date
    @Binding var isShowing: Bool
    
    @State private var startTimeTemp: Date = Date()
    @State private var finishTimeTemp: Date = Date()
    
    
    init(startTime: Binding<Date>, finishTime: Binding<Date>, isShowing: Binding<Bool>) {
        self._startTime = startTime
        self._finishTime = finishTime
        
        self._startTimeTemp = State(initialValue: startTime.wrappedValue)
        self._finishTimeTemp = State(initialValue: finishTime.wrappedValue)
        
        self._isShowing = isShowing
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("От:", selection: $startTimeTemp, displayedComponents: .hourAndMinute)
                    .padding(.leading)
                    .padding(.trailing)
                Divider()
                DatePicker("До:", selection: $finishTimeTemp, displayedComponents: .hourAndMinute)
                    .padding(.leading)
                    .padding(.trailing)
                Spacer()
            }
            .padding(.top)
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
                    Button("Готово") {
                        startTime = startTimeTemp
                        finishTime = finishTimeTemp
                        
                        self.isShowing = false
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    Button("Отменить") {
                        self.isShowing = false
                    }
                }
            }
        }
        .presentation(isModal: true)
    }
}


struct TimeIntervalPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TimeIntervalPickerView(startTime: .constant(Date()), finishTime: .constant(Date()), isShowing: .constant(true))
    }
}
