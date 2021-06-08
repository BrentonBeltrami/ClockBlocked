//
//  DateSelectionSheet.swift
//  BaseCoreData
//
//  Created by Brenton Beltrami on 11/7/20.
//

import SwiftUI



struct DateSelectionSheet: View {
    @Environment(\.presentationMode) var presentation
    
    //current date being show in TimeView
    @Binding var date: Date
    
    
    var body: some View {
        NavigationView{
            VStack{
                Spacer()
                ZStack{
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: UIScreen.main.bounds.width * 0.96, height: 400)
                        .foregroundColor(coloring.secondary)
                        
                
                DatePicker("Date Picker", selection: $date, displayedComponents: .date)
                    .colorMultiply(coloring.text)
                    .accentColor(coloring.accent)
            
                    
                    .background(Color.clear)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .navigationBarTitle(
                        Text(date: date), displayMode: .inline
                    )
                    .onChange(of: date, perform: { value in
                        //Dismissal Bug - Won't load data if dismissed on press
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: {
                            self.presentation.wrappedValue.dismiss()                        
                        })
                    })
                    
                }
                Spacer()
            }
            .background(coloring.background)
            .edgesIgnoringSafeArea(.all)
        }
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}
