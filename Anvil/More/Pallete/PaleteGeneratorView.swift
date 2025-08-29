//
//  PaletteGeneratorView.swift
//  Anvil
//
//  Created by Assistant on 28/8/25.
//

import SwiftUI

struct PaletteGeneratorView: View {
    @Environment(\.colorScheme) var systemColorScheme
    @State private var lightPalette: ColorPalette
    @State private var darkPalette: ColorPalette
    @State private var isDarkMode: Bool = false
    @State private var selectedAppType: SampleAppPreview.AppType = .forms
    @State private var showingExportSuccess = false
    
    // Simple computed property to get current palette
    private var currentPalette: ColorPalette {
        return isDarkMode ? darkPalette : lightPalette
    }
    
    init() {
        _lightPalette = State(initialValue: ColorPalette(isDarkMode: false))
        _darkPalette = State(initialValue: ColorPalette(isDarkMode: true))
    }
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(spacing: 16) {
                    // Sample App Preview
                    sampleAppPreviewSection
                    
                    // App Type Selector
                    appTypeSelectorSection
                    
                    // Color Palette Controls
                    colorPaletteSection
                    

                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(systemColorScheme == .dark ? 0.1 : 0.3),
                        Color.purple.opacity(systemColorScheme == .dark ? 0.1 : 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Palette Generator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Reset Button
                    Button(action: resetPalette) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.purple)
                    }
                    
                    // Dark/Light Mode Toggle
                    Button(action: toggleColorScheme) {
                        Image(systemName: isDarkMode ? "sun.max" : "moon")
                            .foregroundColor(.purple)
                    }
                    
                    // Export Button
                    Button(action: exportPalette) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .alert("Palette Exported!", isPresented: $showingExportSuccess) {
            Button("OK") { }
        } message: {
            Text("Color palette has been copied to your clipboard as JSON.")
        }
    }
    
    // MARK: - Color Palette Section
    private var colorPaletteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Color Palette")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(currentPalette.isDarkMode ? "Dark Mode" : "Light Mode")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.purple)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(currentPalette.items.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 8) {
                            // Color picker with enhanced styling
                            ColorPicker("", selection: Binding(
                                get: { item.color },
                                set: { newColor in
                                    if isDarkMode {
                                        if let itemIndex = darkPalette.items.firstIndex(where: { $0.id == item.id }) {
                                            darkPalette.items[itemIndex].color = newColor
                                        }
                                    } else {
                                        if let itemIndex = lightPalette.items.firstIndex(where: { $0.id == item.id }) {
                                            lightPalette.items[itemIndex].color = newColor
                                        }
                                    }
                                }
                            ), supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                            )
                            
                            // Color name
                            Text(item.name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 20))
        .background(
            Color.gray.opacity(systemColorScheme == .dark ? 0.3 : 0.2),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.purple.opacity(0.3),
                    lineWidth: 8
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - App Type Selector Section
    private var appTypeSelectorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "app.badge")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Preview App Type")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SampleAppPreview.AppType.allCases, id: \.self) { appType in
                        SystemAppTypeButton(
                            appType: appType,
                            isSelected: selectedAppType == appType
                        ) {
                            selectedAppType = appType
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 20))
        .background(
            Color.gray.opacity(systemColorScheme == .dark ? 0.3 : 0.2),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.purple.opacity(0.3),
                    lineWidth: 8
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Sample App Preview Section
    private var sampleAppPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "iphone")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Live Preview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: selectedAppType.icon)
                        .font(.caption)
                        .foregroundColor(.purple)
                    Text(selectedAppType.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 20)
            
            // iPhone 16 frame with sample app
            HStack {
                Spacer()
                iPhone16Frame(isDarkMode: currentPalette.isDarkMode) {
                    SampleAppPreview(palette: currentPalette, appType: selectedAppType)
                }
                .scaleEffect(0.55)
                .frame(height: 400)
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .padding(.vertical, 20)
        .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 20))
        .background(
            Color.gray.opacity(systemColorScheme == .dark ? 0.3 : 0.2),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.purple.opacity(0.3),
                    lineWidth: 8
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Helper Methods
    private func toggleColorScheme() {
        isDarkMode.toggle()
    }
    
    private func resetPalette() {
        lightPalette = ColorPalette(isDarkMode: false)
        darkPalette = ColorPalette(isDarkMode: true)
    }
    
    private func exportPalette() {
        // Helper function to convert color to hex
        func colorToHex(_ color: Color) -> String {
            let uiColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            return String(format: "#%02X%02X%02X", 
                         Int(red * 255), Int(green * 255), Int(blue * 255))
        }
        
        // Helper function to create color dictionary from palette
        func createColorDict(from palette: ColorPalette) -> [String: String] {
            var colorDict: [String: String] = [:]
            for item in palette.items {
                // Convert color names to simple keys
                let key = item.name.lowercased().replacingOccurrences(of: " ", with: "_")
                colorDict[key] = colorToHex(item.color)
            }
            return colorDict
        }
        
        // Create the simplified JSON structure
        let exportData: [String: [String: String]] = [
            "light_mode": createColorDict(from: lightPalette),
            "dark_mode": createColorDict(from: darkPalette)
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                UIPasteboard.general.string = jsonString
                showingExportSuccess = true
            }
        } catch {
            print("Failed to export palette: \\(error)")
        }
    }
}



// MARK: - System App Type Button
struct SystemAppTypeButton: View {
    let appType: SampleAppPreview.AppType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: appType.icon)
                    .font(.subheadline)
                Text(appType.rawValue)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .medium)
            .foregroundColor(isSelected ? .white : .purple)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.purple : Color.purple.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Color.purple.opacity(0.3),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    PaletteGeneratorView()
}
