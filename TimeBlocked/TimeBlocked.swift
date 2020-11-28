//
//  BaseCoreDataApp.swift
//  BaseCoreData
//
//  Created by Brenton Beltrami on 11/5/20.
//

import SwiftUI

@main
struct BaseCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
