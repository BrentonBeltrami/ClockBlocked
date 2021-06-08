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
    
    
    let productIDs = [
        //Use your product IDs instead
        "com.brentonbeltrami.timeBlocked.IAP.spare_change"
    ]
    
    @StateObject var storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(storeManager: storeManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear(perform: {
                    storeManager.getProducts(productIDs: productIDs)
                })
        }
    }
}
