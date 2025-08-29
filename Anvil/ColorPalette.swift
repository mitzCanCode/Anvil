//
//  ColorPalette.swift
//  Anvil
//
//  Created by Assistant on 28/8/25.
//

import SwiftUI

// MARK: - Color Palette Item
struct PaletteItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: Color
    var description: String
    
    // Custom coding keys for JSON export
    private enum CodingKeys: String, CodingKey {
        case name, color, description
    }
    
    // Custom encoding for Color
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        
        // Convert Color to hex string for JSON export
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let hex = String(format: "#%02X%02X%02X", 
                        Int(red * 255), Int(green * 255), Int(blue * 255))
        try container.encode(hex, forKey: .color)
    }
    
    // Custom decoding for Color
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        
        let hexString = try container.decode(String.self, forKey: .color)
        self.color = Color(hex: hexString) ?? .primary
    }
    
    // Regular initializer
    init(name: String, color: Color, description: String) {
        self.name = name
        self.color = color
        self.description = description
    }
}

// MARK: - Color Palette
struct ColorPalette: Codable {
    var items: [PaletteItem]
    var isDarkMode: Bool
    var name: String
    
    init(name: String = "Custom Palette", isDarkMode: Bool = false) {
        self.name = name
        self.isDarkMode = isDarkMode
        
        // Default palette based on current app colors
        if isDarkMode {
            self.items = [
                PaletteItem(name: "Primary", color: Color.purple, description: "Main brand color"),
                PaletteItem(name: "Secondary", color: Color.blue, description: "Secondary accent color"),
                PaletteItem(name: "Background", color: Color(red: 0.11, green: 0.11, blue: 0.12), description: "Main background"),
                PaletteItem(name: "Surface", color: Color(red: 0.15, green: 0.15, blue: 0.17), description: "Card/surface background"),
                PaletteItem(name: "Text Primary", color: Color.white, description: "Primary text color"),
                PaletteItem(name: "Text Secondary", color: Color(red: 0.7, green: 0.7, blue: 0.7), description: "Secondary text color")
            ]
        } else {
            self.items = [
                PaletteItem(name: "Primary", color: Color.purple, description: "Main brand color"),
                PaletteItem(name: "Secondary", color: Color.blue, description: "Secondary accent color"),
                PaletteItem(name: "Background", color: Color.white, description: "Main background"),
                PaletteItem(name: "Surface", color: Color(red: 0.95, green: 0.95, blue: 0.97), description: "Card/surface background"),
                PaletteItem(name: "Text Primary", color: Color.black, description: "Primary text color"),
                PaletteItem(name: "Text Secondary", color: Color(red: 0.4, green: 0.4, blue: 0.4), description: "Secondary text color")
            ]
        }
    }
    
    // Helper methods to get specific colors
    var primary: Color { items.first { $0.name == "Primary" }?.color ?? .purple }
    var secondary: Color { items.first { $0.name == "Secondary" }?.color ?? .blue }
    var background: Color { items.first { $0.name == "Background" }?.color ?? Color(.systemBackground) }
    var surface: Color { items.first { $0.name == "Surface" }?.color ?? Color(.secondarySystemBackground) }
    var textPrimary: Color { items.first { $0.name == "Text Primary" }?.color ?? Color(.label) }
    var textSecondary: Color { items.first { $0.name == "Text Secondary" }?.color ?? Color(.secondaryLabel) }
    
    // Generate smart dark mode suggestions based on light mode colors
    static func generateDarkModeFromLight(_ lightPalette: ColorPalette) -> ColorPalette {
        var darkPalette = ColorPalette(name: lightPalette.name + " (Dark)", isDarkMode: true)
        
        for item in lightPalette.items {
            let darkColor: Color
            switch item.name {
            case "Primary", "Secondary":
                // Keep accent colors exactly the same
                darkColor = item.color
            case "Background":
                // Use dark background
                darkColor = Color(red: 0.11, green: 0.11, blue: 0.12) // Dark gray background
            case "Surface":
                // Use slightly lighter surface for cards
                darkColor = Color(red: 0.15, green: 0.15, blue: 0.17) // Slightly lighter dark gray
            case "Text Primary":
                // White text for dark mode
                darkColor = Color.white
            case "Text Secondary":
                // Light gray text for secondary
                darkColor = Color(red: 0.7, green: 0.7, blue: 0.7)
            default:
                // For any other colors, keep them the same
                darkColor = item.color
            }
            
            if let index = darkPalette.items.firstIndex(where: { $0.name == item.name }) {
                darkPalette.items[index].color = darkColor
            }
        }
        
        return darkPalette
    }
    
    // Generate light mode suggestions based on dark mode colors
    static func generateLightModeFromDark(_ darkPalette: ColorPalette) -> ColorPalette {
        var lightPalette = ColorPalette(name: darkPalette.name.replacingOccurrences(of: " (Dark)", with: ""), isDarkMode: false)
        
        for item in darkPalette.items {
            let lightColor: Color
            switch item.name {
            case "Primary", "Secondary":
                // Keep accent colors exactly the same
                lightColor = item.color
            case "Background":
                // Use light background
                lightColor = Color.white
            case "Surface":
                // Use slightly gray surface for cards
                lightColor = Color(red: 0.95, green: 0.95, blue: 0.97) // Very light gray
            case "Text Primary":
                // Dark text for light mode
                lightColor = Color.black
            case "Text Secondary":
                // Dark gray text for secondary
                lightColor = Color(red: 0.4, green: 0.4, blue: 0.4)
            default:
                // For any other colors, keep them the same
                lightColor = item.color
            }
            
            if let index = lightPalette.items.firstIndex(where: { $0.name == item.name }) {
                lightPalette.items[index].color = lightColor
            }
        }
        
        return lightPalette
    }
}

// MARK: - Color Extensions
extension Color {
    // Initialize Color from hex string
    init?(hex: String) {
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
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Adjust color for dark mode (make slightly brighter/more saturated)
    func adjustedForDarkMode() -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Increase brightness and slightly reduce saturation for dark mode
        let newBrightness = min(brightness * 1.2, 1.0)
        let newSaturation = saturation * 0.9
        
        return Color(UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: alpha))
    }
    
    // Adjust color for light mode (make slightly darker/less saturated)
    func adjustedForLightMode() -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Decrease brightness and increase saturation for light mode
        let newBrightness = brightness * 0.8
        let newSaturation = min(saturation * 1.1, 1.0)
        
        return Color(UIColor(hue: hue, saturation: newSaturation, brightness: newBrightness, alpha: alpha))
    }
}
