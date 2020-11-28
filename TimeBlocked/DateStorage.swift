//
//  DateStorage.swift
//  BaseCoreData
//
//  Created by Brenton Beltrami on 11/9/20.
//

import SwiftUI

struct DateStore: Codable {
    var date : String
}

//MARK: TODO - Save array
class DateStorage: ObservableObject {
    @Published var dateList = [DateStore]() {
        didSet {
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(dateList) {
                UserDefaults.standard.set(encoded, forKey: "Dates")
            }
        }
    }
    
    init() {
        if let dateList = UserDefaults.standard.data(forKey: "Dates") {
            let decoder = JSONDecoder()
            
            if let decoded = try? decoder.decode([DateStore].self, from: dateList) {
                self.dateList = decoded
                return
            }
        }
        
        self.dateList = []
    }
    
}
