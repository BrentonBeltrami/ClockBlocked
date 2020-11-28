//
//  ItemView.swift
//  BaseCoreData
//
//  Created by Brenton Beltrami on 11/7/20.
//

import SwiftUI

struct ItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var item: Item
    
    var textColor: Color
    
    var body: some View {
        let text = Binding(
            get: { item.title ?? "" },
            set: { item.title = $0 }
        )
        // now binding over item title is provided by ObservedObject wrapper
        TextField("", text: text, onEditingChanged: {_ in
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }, onCommit: {
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        })
        .foregroundColor(textColor)

    }
}
