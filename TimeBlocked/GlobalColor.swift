//
//  GlobalColor.swift
//  BaseCoreData
//
//  Created by Brenton Beltrami on 11/11/20.
//

import SwiftUI


//MARK: Global Variables for managing theme
let defaults = UserDefaults.standard
var colorCodes = defaults.object(forKey: "ColorCodes") as? [String] ?? ["#333a45", "#f44c7f", "#939eae", "#e9ecf0" ,"#da3333"]

//Current Theme being shown
var coloring = colors(background: Color(hex: colorCodes[0]), accent: Color(hex: colorCodes[1]),secondary: Color(hex: colorCodes[2]),text: Color(hex: colorCodes[3]),canceled: Color(hex: colorCodes[4]))
var darkMode = defaults.optionalBool(forKey: "darkMode") ?? true

//function to update navbar colors
func updateNavBarColor() {
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(coloring.text)]
    UINavigationBar.appearance().barTintColor = UIColor(coloring.background)
    UINavigationBar.appearance().backgroundColor = UIColor(coloring.background)
}


//struct for managing theme
struct colors: Hashable {
    var background: Color
    var accent: Color
    var secondary: Color
    var text: Color
    var canceled: Color
}


//Hex string to Color converter
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

