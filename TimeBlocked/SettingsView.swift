//
//  SettingsView.swift
//  BaseCoreData
//
//  Created by Brenton Beltrami on 11/10/20.
//

import SwiftUI

enum ButtonSizes: Identifiable {
    case small, medium, large
    
    var id: Int {
        hashValue
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentation
    
    @StateObject var storeManager: StoreManager
    
    
    //array for the start & end time pickers
    var startTimes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    var endTimes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    
    
    //start & end times that show in the day view
    @Binding var selectedStart: Int
    @Binding var selectedEnd: Int
    
    
    @Binding var isTimeLeft: Bool
    
    
    @Binding var navButtonSize: Int
    @Binding var checkButtonSize: Int
    
    @Binding var swipeSensitivity: Int
    
    @Binding var showSavedSheet: Bool
    
    
    @State var showFunctionSettings = false
    @State var showDisplaySettings = false
    
    
    @State var showOtherSettings = false
    @State var hasTipped = false
    
    
    
    
    let current = UNUserNotificationCenter.current()
    @State var notificationApproved = false
    
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    
                    
                    
//MARK: - Functionality
                        Button(action: {
                            showFunctionSettings.toggle()
                        }, label: {
                            HStack{
                                Text("Functionality")
                                    .foregroundColor(coloring.text)
                                    .bold()
                                
                            Spacer()
                            
                                Image(systemName: "chevron.down.circle")
                                    .buttonModifier(size: navButtonSize)
                                    .foregroundColor(coloring.accent)
                                    .rotationEffect(Angle(degrees: showFunctionSettings ? -180 : 0))
                                
                            }
                        })
                        
                        .listRowBackground(coloring.background)

                    
                    if showFunctionSettings {
                        
    //MARK:  Reminders
                        
                        //hides notification request if permissons have been given or denied.
                        if checkNotificationPermissions() {
                            Section(header: Text("Reminders")
                                        .foregroundColor(coloring.accent)
                            ){
                                Button {
                                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                        if success {
                                            print("All set!")
                                        } else if let error = error {
                                            print(error.localizedDescription)
                                        }
                                    }
                                } label: {
                                    Text("Enable Notifications")
                                        .foregroundColor(coloring.text)
                                }
                            }
                            .listRowBackground(coloring.secondary)
                        }
                        

    //MARK:  Time Pickers
                        Section(header: Text("Day Start / End")
                                    .foregroundColor(coloring.accent)
                        ){
                            HStack{
                            Picker(selection: $selectedStart, label: Text("Start Time")) {
                                ForEach(0 ..< startTimes.count) { index in
                                    if index == 0 {
                                        Text("\(self.startTimes[index] + 12) am")
                                        
                                            .foregroundColor(coloring.text)
                                        
                                        let _ = UserDefaults.standard.set(selectedStart, forKey: "StartTime")
                                    } else {
                                        Text("\(self.startTimes[index]) am")
                                            .foregroundColor(coloring.text)
                                        
                                        let _ = UserDefaults.standard.set(selectedStart, forKey: "StartTime")
                                    }

                                }
                            }.pickerStyle(WheelPickerStyle())
                            .frame(width: UIScreen.main.bounds.width * 0.40, height: 125)
                            .clipped()
                            
                            Picker(selection: $selectedEnd, label: Text("End Time")) {
                                ForEach(0 ..< endTimes.count) { index in
                                    if index == 0 {
                                        Text("\(self.endTimes[index] + 12) pm")
                                            .foregroundColor(coloring.text)
                                        let _ = UserDefaults.standard.set(selectedEnd, forKey: "EndTime")
                                    } else {
                                        Text("\(self.endTimes[index]) pm")
                                            .foregroundColor(coloring.text)
                                        let _ = UserDefaults.standard.set(selectedEnd, forKey: "EndTime")
                                    }

                                }
                            }.pickerStyle(WheelPickerStyle())
                            .frame(height: 125)
                            .frame(width: UIScreen.main.bounds.width * 0.40, height: 125)
                            .clipped()
                            .padding(.trailing)
                                
                            }

                        }
                        .listRowBackground(coloring.secondary)

                        
                        
    //MARK:  Saved Task Sheet Toggle
                        Section(header: Text("Saved Task List")
                                    .foregroundColor(coloring.accent)
                        ){
                            
                            Toggle("Show In Long-Press Menu", isOn: $showSavedSheet)
                                .foregroundColor(coloring.text)
                                .onReceive([self.showSavedSheet].publisher.first()) { _ in
                                        let _ = UserDefaults.standard.set(showSavedSheet, forKey: "ShowSavedSheet")
                                   }
                        }
                        .listRowBackground(coloring.secondary)
             
                        
                        
    //MARK:  Swipe Sensitivity
                        Section(header: Text("Swipe Sensitivity")
                                    .foregroundColor(coloring.accent)
                        ){
      
                            Picker(selection: $swipeSensitivity, label: Text("Swipe Sensitivity")) {
                                Text("Low").tag(200)
                                Text("Medium").tag(100)
                                Text("High").tag(25)
                                
                                let _ = UserDefaults.standard.set(swipeSensitivity, forKey: "SwipeSensitivity")
                            }.pickerStyle(SegmentedPickerStyle())
                            
                            
                        }
                        .listRowBackground(coloring.secondary)
                        
                    }
//MARK: - Display
                        Button(action: {
                            showDisplaySettings.toggle()
                        }, label: {
                            HStack{
                                Text("Display")
                                    .foregroundColor(coloring.text)
                                    .bold()
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down.circle")
                                    .buttonModifier(size: navButtonSize)
                                    .foregroundColor(coloring.accent)
                                    .rotationEffect(Angle(degrees: showDisplaySettings ? -180 : 0))
                                
                            }
                        })
                        .listRowBackground(coloring.background)
                    
                    
                    
                    
                    if showDisplaySettings {
//MARK: - Button Size Settings
                    Section(header: Text("Navigation Bar Button Sizes")
                                .foregroundColor(coloring.accent)
                    ){
                        Picker(selection: $navButtonSize, label: Text("Nav Button Size")) {
                            Text("Small").tag(0)
                                .foregroundColor(coloring.text)
                            Text("Medium").tag(1)
                                .foregroundColor(coloring.text)
                            Text("Large").tag(2)
                                .foregroundColor(coloring.text)
                            
                            let _ = UserDefaults.standard.set(navButtonSize, forKey: "NavButtonSize")
                        }.pickerStyle(SegmentedPickerStyle())
                        
                    }
                    .listRowBackground(coloring.secondary)

                    Section(header: Text("Checkmark Button Sizes")
                                .foregroundColor(coloring.accent)
                    ){
  
                        Picker(selection: $checkButtonSize, label: Text("Checkmark Button Size")) {
                            Text("Small").tag(0)
                                .foregroundColor(coloring.text)
                            Text("Medium").tag(1)
                                .foregroundColor(coloring.text)
                            Text("Large").tag(2)
                                .foregroundColor(coloring.text)
                            
                            let _ = UserDefaults.standard.set(checkButtonSize, forKey: "CheckButtonSize")
                        }.pickerStyle(SegmentedPickerStyle())
                        
                        
                    }
                    .listRowBackground(coloring.secondary)
                    
                    
                    
                    
    //MARK: - Time Indicator
                        Section(header: Text("Time Indicator Location")
                                    .foregroundColor(coloring.accent)
                        ){
                        
                            Button(action: {
                                isTimeLeft.toggle()
                                defaults.set(isTimeLeft, forKey: "isTimeLeft")
                            }, label: {
                                Text(isTimeLeft ? "Move Time Indicator To Right" : "Move Time Indicator To Left")
                                    .foregroundColor(coloring.text)
                            })
                        }
                        .listRowBackground(coloring.secondary)
                        

                        
//MARK: - Persistent Settings Views
//                        Section(header: Text("Expand Settings Categories")
//                                    .foregroundColor(coloring.accent)
//                        ){
//
//
//                            Toggle("Always Show Funcionality Settings", isOn: $showFunctionSettings)
//                                .onReceive([self.showFunctionSettings].publisher.first()) { _ in
//                                        let _ = UserDefaults.standard.set(showFunctionSettings, forKey: "ShowFunctionSettings")
//                                   }
//                            Toggle("Always Show Display Settings", isOn: $showDisplaySettings)
//                                .onReceive([self.showDisplaySettings].publisher.first()) { _ in
//                                        let _ = UserDefaults.standard.set(showDisplaySettings, forKey: "ShowDisplaySettings")
//                                   }
//                        }
//                        .listRowBackground(coloring.secondary)
                    
                    
                    
//MARK: - Theme Selection
                    Section(header: Text("Select Theme")
                                .foregroundColor(coloring.accent)
//MARK: HEXCODE KEY: bg-color, main-color, sub-color, text-color, error-color
                    ){
                        Group{
                        //1.0-1.2 themes
                            Button(action: {
                                colorCodes = ["#333a45", "#f44c7f", "#939eae", "#e9ecf0" ,"#da3333"]
                                newColorCodes(codes: colorCodes)
                                darkMode = true
                            }, label: {
                                Text("8008")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#eeebe2", "#080909", "#99947f", "#080909" ,"#c87e74"]
                                newColorCodes(codes: colorCodes)
                                darkMode = false
                            }, label: {
                                Text("9009")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#101820", "#eedaea", "#cf6bdd", "#eedaea" ,"#ff5253"]
                                newColorCodes(codes: colorCodes)
                                darkMode = true
                            }, label: {
                                Text("aether")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#afcbdd", "#fcfbf6", "#85a5bb", "#1a2633" ,"#bf616a"]
                                newColorCodes(codes: colorCodes)
                                darkMode = false
                            }, label: {
                                Text("mizu")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#030613", "#4fcdb9", "#1e283a", "#e2f1f5" ,"#e32b2b"]
                                newColorCodes(codes: colorCodes)
                                darkMode = true
                            }, label: {
                                Text("hammerhead")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#a4a7ea", "#e368da", "#7c7faf", "#f1ebf1" ,"#573ca9"]
                                newColorCodes(codes: colorCodes)
                                darkMode = true
                            }, label: {
                                Text("vaporwave")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#ffffff", "#f5b1cc", "#93e8d3", "#00ac8c" ,"#ffe495"]
                                newColorCodes(codes: colorCodes)
                                darkMode = false
                            }, label: {
                                Text("magic girl")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#091f2c", "#f5b1cc", "#a288d9", "#93e8d3" ,"#e45c96"]
                                newColorCodes(codes: colorCodes)
                                darkMode = true
                            }, label: {
                                Text("dark magic girl")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#84202c", "#c79e6e", "#55131b", "#e2dad0" ,"#33bbda"]
                                newColorCodes(codes: colorCodes)
                                darkMode = true
                            }, label: {
                                Text("red samurai")
                                    .foregroundColor(coloring.text)
                            })
                            Button(action: {
                                colorCodes = ["#000000", "#15ff00", "#003B00", "#adffa7" ,"#da3333"]
                                newColorCodes(codes: colorCodes)
                                darkMode = true
                            }, label: {
                                Text("matrix")
                                    .foregroundColor(coloring.text)
                            })
                        }
                    }
                    .listRowBackground(coloring.secondary)
                    
                    }
                    
                    
                    
//MARK: - Other
//                    Button(action: {
//                        showOtherSettings.toggle()
//                    }, label: {
//                        HStack{
//                            Text("Other")
//                                .foregroundColor(coloring.text)
//                                .bold()
//
//                            Spacer()
//
//                            Image(systemName: "chevron.down.circle")
//                                .buttonModifier(size: navButtonSize)
//                                .foregroundColor(coloring.accent)
//                                .rotationEffect(Angle(degrees: showOtherSettings ? -180 : 0))
//
//                        }
//                    })
//
//                    .listRowBackground(coloring.background)
                
                
                    if showOtherSettings {
                        Section(header: Text("Tip The Developer")
                                    .foregroundColor(coloring.accent)
                        ){
                            Text("Thank you for using TimeBlocked. I hope you are enjoying it. I want all features to be available to all users regardless of their financial position. The tip below is only if you would like to support me. It does not unlock anything special. Thank you.")
                                .foregroundColor(coloring.text)
                                .padding([.top, .bottom])

                            List(storeManager.myProducts, id: \.self) { product in
                                HStack {

                                    //Description
                                    Text(product.localizedTitle)
                                        .foregroundColor(coloring.secondary)
                                        .strikethrough()
                                        .opacity(0.3)

                                    Spacer()

                                    //Button
                                    if UserDefaults.standard.bool(forKey: product.productIdentifier) {
                                        Text ("Purchased!")
                                            .foregroundColor(coloring.text)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .foregroundColor(coloring.accent)
                                                    .opacity(0.3)
                                                    .padding(-5)
                                            )
                                    } else {
                                        Button(action: {


                                            //Purchase particular ILO product



                                        }) {

                                            Text("$\(product.price)")
                                                .foregroundColor(coloring.text)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .foregroundColor(coloring.accent)
                                                        .opacity(0.5)
                                                        .padding(-5)
                                                )
                                        }
                                    }
                                }
                            }


                        }
                        .listRowBackground(coloring.secondary)




                    }
                
                
                
                }
                
                
                
                
            }.navigationBarTitle("Settings", displayMode: .inline)
            
            
            
            
            .background(coloring.background)
            .ignoresSafeArea()
            
            
            
            
            
            

        }
        //force updates navBar when new theme is applied
        .id(coloring)
        .preferredColorScheme(darkMode ? .dark : .light)
        
        
    }
    
    

//MARK: - Functions
    
    
    //takes array of hexcodes & applies them as a theme
    func newColorCodes(codes: [String]) {
        //sets array of codes
        let newTheme = colors(background: Color(hex: codes[0]), accent: Color(hex: codes[1]),secondary: Color(hex: codes[2]),text: Color(hex: codes[3]),canceled: Color(hex: codes[4]))
        //applies newTheme to default
        coloring = newTheme
        
        //force update state
        updateNavBarColor()
        forceReload()
        
        
        //save theme to default
        let defaults = UserDefaults.standard
        defaults.set(codes, forKey: "ColorCodes")
        
        //dismiss sheet view in order to avoid multiple sheets bug
        self.presentation.wrappedValue.dismiss()
    }
    
    
    //forces state change to update theme in Settings & TimeView
    func forceReload() {
        let current = selectedEnd
        selectedEnd = 1
        selectedEnd  = current
    }
    
    func checkNotificationPermissions() -> Bool {
        
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
                notificationApproved = true
            } else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
                notificationApproved = false
            } else if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
                notificationApproved = false
            }
        })
        
        return notificationApproved
    }
    
    
    
    
}




//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}



extension AnyTransition {
    static func moveAndFade(edge: Edge, offsetX: CGFloat, offsetY: CGFloat) -> AnyTransition {
        AnyTransition.move(edge: edge).combined(with: .opacity).combined(with: offset(x: offsetX, y: offsetY))
    }
}

extension View {
    func animationModifier(offsetX: CGFloat, offsetY: CGFloat) -> some View {
        self
            .transition(.moveAndFade(edge: .leading, offsetX: offsetX, offsetY: offsetY))
            .animation(.spring())
            .frame(width: 50, height: 50)
    }
}
