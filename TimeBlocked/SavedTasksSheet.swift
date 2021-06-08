//
//  SavedTasksSheet.swift
//  BaseCoreData
//
//  Created by Brenton Beltrami on 11/10/20.
//
import SwiftUI

//MARK: Struct for tasks to be saved
struct TaskStore: Identifiable, Codable {

    let id = UUID()
    var item : String
}

//MARK: Class for managing & saving TaskStore objects
class TasksStorage: ObservableObject {
    @Published var taskList = [TaskStore]() {
        didSet {
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(taskList) {
                UserDefaults.standard.set(encoded, forKey: "Tasks")
            }
        }
    }
    
    init() {
        if let taskList = UserDefaults.standard.data(forKey: "Tasks") {
            let decoder = JSONDecoder()
            
            if let decoded = try? decoder.decode([TaskStore].self, from: taskList) {
                self.taskList = decoded
                return
            }
        }
        
        self.taskList = []
    }
    
}



struct SavedTasksSheet: View {
    //is sheet being shown
    @Environment(\.presentationMode) var presentation
    
    //items in saved storage
    @ObservedObject var tasks: TasksStorage
    
    //for adding new item to TasksStorage
    @State var title = ""
    
    
    //the item/row that launched the sheet
    @Binding var cellItem: FetchedResults<Item>.Element?
    
    //haptic feedback for button presses
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    
    
    
    var body: some View {
        
        
        NavigationView{
            VStack {
                Spacer().frame(height: 50)
                
                
                //Add new task field & button
                HStack{
                    TextField("Add New Saved Task", text: $title)
                        .foregroundColor(coloring.text)
                    
                    Button(action: {
                        impactMed.impactOccurred()
                        
                        let newTask = TaskStore(item: title)
                        tasks.taskList.append(newTask)
                        self.title = ""
                    }, label: {
                        Text("Save")
                            .foregroundColor(coloring.accent)
                    })
                }.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(coloring.accent, lineWidth: 2)
                )
                .padding()
                
                
                
                Spacer()
                
                
                List{
                    
                    ForEach(tasks.taskList.indices, id:\.self){ index in
                        
                        Button(action: {
                            impactMed.impactOccurred()
                            
                            cellItem!.title = tasks.taskList[index].item
                            self.presentation.wrappedValue.dismiss()
                        }, label: {
                            Text(tasks.taskList[index].item)
                                .foregroundColor(coloring.text)
                        })
                        
//
//                        Text(tasks.taskList[index].item)
//                            .onTapGesture(perform: {
//                                    cellItem!.title = tasks.taskList[index].item
//                                    self.presentation.wrappedValue.dismiss()
//                            })
                        
                        
                    }.onDelete(perform: { indexSet in
                        tasks.taskList.remove(atOffsets: indexSet)
                    })
                    .listRowBackground(coloring.secondary)
                    
                    
                    
                }
                .frame(width: UIScreen.main.bounds.width)
                .listStyle(InsetGroupedListStyle())
                
                
                
                Spacer()
                
            }.navigationBarTitle("Saved Tasks", displayMode: .inline)
            .padding()
            .background(coloring.background)
            .ignoresSafeArea()
            
            
        }
        .preferredColorScheme(darkMode ? .dark : .light)
        
        
    }
}
