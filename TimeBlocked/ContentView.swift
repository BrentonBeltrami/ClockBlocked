//
//  ContentView.swift
//  BaseCoreData
//
//  Created by Brenton Beltrami on 11/5/20.
//

import SwiftUI
import CoreData

//enum for managing show sheet
enum ActiveSheet: Identifiable {
    case date, savedTasks, settings
    
    var id: Int {
        hashValue
    }
}

struct ContentView: View {
    //environment objects
    @Environment(\.managedObjectContext) private var viewContext
    
    //MARK: CoreData objects
//    var _predicate: Date
//    var itemRequest: FetchRequest<Item>
//    var items: FetchedResults<Item>{itemRequest.wrappedValue}
    
//    let predicate = NSPredicate(format: "timestamp >= $selectedDate")
//    // variables in predicates begin with $
//    // in this, "$text" is a variable NSExpression called "text"
//    let matchesObject = predicate.evaluate(with: Item, substitutionVariables: ["text": selectedDate])
//
    
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    

    
    //MARK: StoreManager
    @ObservedObject var storeManager: StoreManager
    
    
    
    //MARK: Date variables
    //variable for all dates ever viewed in app
    @State var allDates = [] as [String]
    
    //currently selected/showing date
    @State var selectedDate = Date()
    
    
    //formating the date to "***day"
    var navDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    
    //setting time indicator to left or right of block text
    @State var isTimeLeft = defaults.bool(forKey: "isTimeLeft")
    
    //showing saved task sheet in contextmenu
    @State var showSavedSheet = defaults.bool(forKey: "ShowSavedSheet")
    
    
    //showing clear all blocks alert
    @State var clearAllAlert = false

    
    //block that started the swap
    @State var swapStoreOne: Item?
    //title of the block ending the swap
    @State var swapTitle: String?
    
    @State var isSwapMode = false
    
    
    //timer to update state when hour changes
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    //Swipe cordinates
    @State private var offset = CGSize.zero
    
    
//MARK: Sheet variables
    //managing what sheet is being show
    @State var activeSheet: ActiveSheet?
    
    //savedSheet variables
    @ObservedObject var tasks = TasksStorage()
    @State var cellItem: FetchedResults<Item>.Element?
    
    //temporary store for all tasks in day for copy & pasting
    @State var itemClipboard = [] as [String]
    
    
    
    
    //haptic feedback for button presses
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    
    
    //setting the start & end hours show in view
    @State var startTime = UserDefaults.standard.integer(forKey: "StartTime")
    @State var endTime = UserDefaults.standard.optionalInt(forKey: "EndTime") ?? 12
    
    
    @State var navButtonSize = UserDefaults.standard.optionalInt(forKey: "NavButtonSize") ?? 2
    @State var checkButtonSize = UserDefaults.standard.optionalInt(forKey: "CheckButtonSize") ?? 2
    
    
    @State var swipeSensitivity = UserDefaults.standard.optionalInt(forKey: "SwipeSensitivity") ?? 100
    @State var hasSwiped = false
    
    //function for overriding default color permissions
    init(storeManager: StoreManager) {
        updateNavBarColor()
        
        UITableView.appearance().backgroundColor = .clear // tableview background
        UITableViewCell.appearance().backgroundColor = .clear // cell background
        
        self.storeManager = storeManager
        
//        self.selectedDate = Date()
//
//        let predicate = NSPredicate(format: "timestamp >= $selectedDate")
//        // variables in predicates begin with $
//        // in this, "$text" is a variable NSExpression called "text"
//        let matchesObject = predicate.evaluate(with: Item.self, substitutionVariables: ["text": selectedDate])
//
//        self.itemRequest = FetchRequest(
//           sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//           predicate: predicate,
//
//           animation: .default
//       )
        
        
//        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
//        var components = DateComponents()
//        components.year = dateComponent.year
//        components.month = dateComponent.month
//        components.day = dateComponent.day
//        components.hour = 0
//        components.minute = 00
//        components.second = 00
//        self._predicate = Calendar.current.date(from: components) ?? Date()
//
//
//        self.itemRequest = FetchRequest(
//            sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//            predicate:NSPredicate(format: "timestamp >= %@", _predicate as NSDate),
//
//            animation: .default
//        )
        

    }
    
    
    
    var body: some View {
        NavigationView{
            List {
                ForEach(items) { item in
                    //set font color depending on completed/skipped/neither
                    let completedColoring = (item.completed ? coloring.secondary : coloring.text)
                    let canceledColoring = (item.skipped ? coloring.canceled : completedColoring)
                    
                    //adjust font weight based on current hour
                    let boldCurrentBlock = boldCurrentHour(itemTime: item.timestamp!)
                    
                    //get hour as Int to check if item is in showed range
                    let itemHour = Calendar.current.dateComponents([.hour], from: item.timestamp!)
                    
                    
                    //show item logic
                    if isToday(item: item) && isBetween(itemHour: itemHour.hour ?? 0) {
                        //Schedule Notifications
                        let _ = notificationScheduler(title: item.title!, timeID: item.id!, time: item.timestamp!, completedORSkipped: (item.skipped || item.completed))
                        
                        
                            HStack{
                                
                                if spacerCurrentHour(itemTime: item.timestamp!) {
                                    Spacer()
                                        .frame(width: 12)
                                }

                                if isTimeLeft {
                                    Text(formatTime(date: item.timestamp ?? Date()))
                                        .font(.caption2)
                                        .fontWeight(boldCurrentBlock)
                                        .foregroundColor(canceledColoring)
                                }
                                    
                                    
                                //TextField in row
                                ItemView(item: item, textColor: canceledColoring)

                                
                                if !isTimeLeft {
                                    Text(formatTime(date: item.timestamp ?? Date()))
                                        .font(.caption2)
                                        .fontWeight(boldCurrentBlock)
                                        .foregroundColor(canceledColoring)
                                }

                            
                                //completion button
                                Button(action: {
                                    if isSwapMode {
                                        swapWithBlock(item: item)
                                    } else {
                                        if item.skipped { item.skipped.toggle() }
                                        item.completed.toggle()
                                        saveContext()
                                    }
                                    
                                    impactMed.impactOccurred()
                                }, label: {
                                    
                                    if isSwapMode {
                                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                                            .buttonModifier(size: checkButtonSize)
                                            .foregroundColor(coloring.accent)
                                    } else {
                                        Image(systemName: item.skipped ? "xmark.circle.fill" : "checkmark.circle.fill")
                                            .buttonModifier(size: checkButtonSize)
                                            .foregroundColor(coloring.accent)
                                            .onTapGesture(count: 2) {
                                                item.skipped.toggle()
                                                impactMed.impactOccurred()
                                                saveContext()
                                            }
                                    }
                                    
                                        
                                })
                                .buttonStyle(BorderlessButtonStyle())
                            
                            
                            
                            
                        }//end of HStack
                            .contextMenu(ContextMenu(menuItems: {
                                //clipboard options in contextMenu
                                Section(header: Text("Clipboard Options")
                                            .foregroundColor(coloring.accent)
                                ){
                                    Group{
                                        Button(action: {
                                            item.title = ""
                                            impactMed.impactOccurred()
                                        },label:{
                                            Text("Clear Block")
                                        })
                                        
                                        
                                        Button(action: {
                                            let pasteBoard = UIPasteboard.general
                                            impactMed.impactOccurred()
                                            pasteBoard.string = item.title
                                        },label:{
                                            Text("Copy Block")
                                        })
                                        Button(action: {
                                            let pasteBoard = UIPasteboard.general
                                            if let string = pasteBoard.string {
                                                item.title = string
                                            }
                                        }, label: {
                                            Text("Paste To Block")
                                        })
                                
                                        Button(action: {
                                            if swapStoreOne == nil {
                                                swapStoreOne = item
                                                isSwapMode = true
                                            } else {
                                                
                                                swapWithBlock(item: item)
                                                
                                            }
                                        }, label: {
                                            Text(swapStoreOne == nil ? "Start Swap" : "Swap With \(formatTime(date: swapStoreOne!.timestamp!))")
                                        })
                                        
                                        
                                    }
                                }
                                
                                if showSavedSheet {
                                    Button("Saved Tasks", action: {
                                        impactMed.impactOccurred()
                                        activeSheet = .savedTasks
                                        cellItem = item
                                    })
                                }
                            }))
                            .alert(isPresented: $clearAllAlert) {
                                Alert(title: Text("Clear All Blocks For \(navDateFormatter.string(from: selectedDate))?"), message: Text("This is permanent!"), primaryButton: .destructive(Text("Clear All")) {
                                        clearAllItems()
                                }, secondaryButton: .cancel())
                            }

                            
                        
                    }//end of show item logic
                    
                }//end of foreach
                .listRowBackground(coloring.background)
                
            }//end of list
            .listStyle(InsetListStyle())
            .background(coloring.background)
            .ignoresSafeArea(.container)
            .navigationBarTitle("\(navDateFormatter.string(from: selectedDate))", displayMode: .inline)
            
            //button to show dateSelectionSheet
            .navigationBarItems(leading: Button(action: {
                activeSheet = .date
                impactMed.impactOccurred()
            }, label: {
                Image(systemName: "calendar")
                    .buttonModifier(size: navButtonSize)
                    .foregroundColor(coloring.accent)
            }))
            
            //toolbar for copy/paste/clear & settings
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        menuItems
                    }
                    label: {
                        Image(systemName: "ellipsis.circle")
                            .buttonModifier(size: navButtonSize)
                            .foregroundColor(coloring.accent)
                            
                    }.padding(.trailing, 10)
                }
            }
            
            //sheets for settings/dateSelector/savedTasks
            .sheet(item: $activeSheet) { item in
                switch item {
                case .settings:
                    SettingsView(storeManager: storeManager, selectedStart: $startTime, selectedEnd: $endTime, isTimeLeft: $isTimeLeft, navButtonSize: $navButtonSize, checkButtonSize: $checkButtonSize, swipeSensitivity: $swipeSensitivity, showSavedSheet: $showSavedSheet)
                case .date:
                    DateSelectionSheet(date: $selectedDate)
                case .savedTasks:
                    SavedTasksSheet(tasks: self.tasks, cellItem: $cellItem)
                }
            }
            .onChange(of: selectedDate, perform: { _ in
                createDayData(dateCheck: selectedDate)
            })
            .onAppear() {
                //MARK: - TODO Create first run user defaults for showing intro
                UIScrollView.appearance().keyboardDismissMode = .interactive
                createDayData(dateCheck: selectedDate)
                

//MARK: an attempt at filtering the list of items
//                testItems = items.filter {
//                    return isToday(item: $0)
//                }
                
                
                
                

            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.offset = gesture.translation
                        
                        if self.offset.width > CGFloat(swipeSensitivity) && !hasSwiped {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            hasSwiped = true
                        }
                        
                        if self.offset.width < CGFloat(-swipeSensitivity) && !hasSwiped {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            hasSwiped = true
                        }
                        
                        
                        
                    }
                    .onEnded { _ in
                        hasSwiped = false
                        
                        if self.offset.width > CGFloat(swipeSensitivity) {
                            
                            previousNextDate(timeJump: -86400)
                            
                        } else if self.offset.width < CGFloat(-swipeSensitivity) {
                            
                            previousNextDate(timeJump: 86400)
                            
                        } else {
                            self.offset = .zero
                        }
                    }
            )
            
            
        }
        //force updates navBar state on theme change
        .id(coloring)
        .preferredColorScheme(darkMode ? .dark : .light)
        .onReceive(timer) { _ in
            let curHour = Calendar.current.dateComponents([.hour, .minute], from: Date())
            
            //force sate update if new hour
            if curHour.minute! == 00 {
                let forceState = endTime
                endTime = 12
                endTime = forceState
            }
        }
        
    }
    
    
    
    
    
    

    
    
    
    
    
    
    //MARK: - Functions for making changes to the dataModel
    @ObservedObject var datesSaved = DateStorage()
    
    //data initalizer for days viewed
    func createDayData(dateCheck: Date) {
        //formatting for dates - mm/dd/yy
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        let dateString = formatter.string(from: dateCheck)
        
        
        //userdefaults for dates
        let defaults = UserDefaults.standard
        
        
        //if allDates is empty create first array in userDefaults
        if allDates.count == 0 {
            allDates = defaults.object(forKey: "SavedDates") as? [String] ?? [String]()
            defaults.set(allDates, forKey: "SavedDates")
        }
        
        
        // if allDates doesnt include current date then create new objects for the date
        if !allDates.contains(dateString) {
            allDates.append(dateString)
            allDates.sort()
            
            for i in 0..<24 {
                addItem(date: setHour(hour: i))
            }
            
            //save current date to allDates in userdefaults
            defaults.set(allDates, forKey: "SavedDates")
        }
    }
    
    //create time-stamps the hour for data objects
    func setHour(hour: Int) -> Date {
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        
        
        var components = DateComponents()
        components.year = dateComponent.year
        components.month = dateComponent.month
        components.day = dateComponent.day
        components.hour = hour
        components.minute = 00
        components.second = 00
        let date = Calendar.current.date(from: components) ?? Date()
        
        return date
    }
    
    //creating items for the data model
    private func addItem(date: Date) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = date
            newItem.title = ""
            newItem.id = UUID()
            newItem.skipped = false
            newItem.completed = false
            
            saveContext()
        }
    }
    
    //save all changes made to data model
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    //MARK: - Functions for showing items in day view
    //check if item has a time stamp for today
    func isToday(item: FetchedResults<Item>.Element) -> Bool {
        var dateCompareFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }
        
        
        let curdate = item.timestamp
        return (dateCompareFormatter.string(from: curdate!) == dateCompareFormatter.string(from: selectedDate) ? true : false)
    }
    
    // check if item is between startTime & endTime set in settings
    func isBetween(itemHour: Int) -> Bool {
        let adjustedEndTime = endTime + 12
        
        if startTime ... adjustedEndTime ~= itemHour {
            return true
        }
        
        return false
    }
    
    
    
    //MARK: - Function for notifications
    //schedule & cancel notifications
    func notificationScheduler(title: String, timeID: UUID, time: Date, completedORSkipped: Bool) {
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        
        
        if title != "" && !completedORSkipped {
            let content = UNMutableNotificationContent()
            
            //set notification content
            content.title = "\(title)"
            content.sound = UNNotificationSound.default
            
            
            //set notification time
            var date = DateComponents()
            date.year = dateComponent.year
            date.month = dateComponent.month
            date.day = dateComponent.day
            date.hour = dateComponent.hour
            date.minute = dateComponent.minute
            let dateTrigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            
            
            
            // schedule notification
            let request = UNNotificationRequest(identifier: "\(timeID)", content: content, trigger: dateTrigger)
            
            // add our notification request
            UNUserNotificationCenter.current().add(request)
        }
        if title == "" {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(timeID)"])
        }
        if completedORSkipped {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(timeID)"])
        }
    }
    
    
    //MARK: - functions to copy/paste/clear all tasks in day
    //paste all tasks for the day
    func pasteAllItems() {
        var n = 0
        for item in items {
            if isToday(item: item) {
                item.title = itemClipboard[n]
                n += 1
            }
            
        }
        
        saveContext()
    }
    
    //clear all tasks for the day
    func clearAllItems() {
        for item in items {
            if isToday(item: item) {
                item.title = ""
            }
        }
        
        saveContext()
    }
    
    //copy all tasks for the day
    func copyAllitems() {
        itemClipboard.removeAll()
        for item in items {
            if isToday(item: item) {
                itemClipboard.append(item.title ?? "")
            }
        }
    }
    
    
    
    
//MARK: functions for modifying text style
    func boldCurrentHour(itemTime: Date) -> Font.Weight {
        let date = Date()
        
        let hour = Calendar.current.dateComponents([.day, .hour], from: date)
        
        let curHour = Calendar.current.dateComponents([.day, .hour], from: itemTime)
        
        return (curHour == hour ? Font.Weight.bold : Font.Weight.light)
    }
    
    //format time from date object for row
    func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)
        
        return dateString
    }
    
    //create spacer for current hour
    func spacerCurrentHour(itemTime: Date) -> Bool {
        let date = Date()
        
        let hour = Calendar.current.dateComponents([.day, .hour], from: date)
        
        let curHour = Calendar.current.dateComponents([.day, .hour], from: itemTime)
        
        return curHour == hour
    }
    
    
    
    
    
    //Force reload UI by chaning state & back
    func forceReload() {
        let current = endTime
        endTime = 1
        endTime  = current
    }
    
    //function for handling back forward swipe
    func previousNextDate(timeJump: Double) {
        
        //jump date by 24 hours
        let temp = selectedDate.addingTimeInterval(timeJump)
        
        //set displayed date to new date
        selectedDate = temp
        
        //formating date to check if in allDates
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd"
        let dateString = formatter.string(from: temp)
        
        
        //this checks to see if date already exists & if not then forceReload state
        //this check prevents jumping bug due to unnessecary state change when date already exists
        if !allDates.contains(dateString) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5), execute: {
                forceReload()
            })
        }
    }
    
    
    
    //MARK: - Drop Down Menu Items
    var menuItems: some View {
        Group {
            Button("Clear All Blocks", action: {clearAllAlert = true})
            Button("Copy All Blocks", action: {copyAllitems()})
            if itemClipboard != [] {
                Button("Paste All Copied Blocks", action: {pasteAllItems()})
            }
            Button("Settings", action: { activeSheet = .settings})
        }
    }
    
    //MARK: - Swapping Function
        func swapWithBlock(item: Item) {
            swapTitle = item.title
            
            item.title = swapStoreOne!.title
            
            for curItem in items {
                if curItem == swapStoreOne {
                    curItem.title = swapTitle
                }
            }
            swapStoreOne = nil
                
            isSwapMode = false
            saveContext()
        }
    
    
    
    
    
    
    
}













struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(storeManager: StoreManager())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


extension Image {
    func buttonModifier(size: Int) -> some View {
        if size == 0 {
            
            return self
                .imageScale(.small)
        }
        else if size == 1 {
            return self
                .imageScale(.medium)
        }
        else {
            return self
                .imageScale(.large)
        }
            
    }
}


extension Text {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    init(date: Date) {
        self.init(Text.dateFormatter.string(from: date))
    }
}


extension UserDefaults {

    public func optionalInt(forKey defaultName: String) -> Int? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Int
        }
        return nil
    }

    public func optionalBool(forKey defaultName: String) -> Bool? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Bool
        }
        return nil
    }
}



//
//extension View {
//    func resignKeyboardOnDragGesture() -> some View {
//        return modifier(ResignKeyboardOnDragGesture())
//    }
//}
//
//struct ResignKeyboardOnDragGesture: ViewModifier {
//    var gesture = DragGesture().onChanged { _ in
//        UIApplication.shared.endEditing(true)
//    }
//    func body(content: Content) -> some View {
//        content.gesture(gesture)
//    }
//}
