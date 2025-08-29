//
//  iPhone16Frame.swift
//  Anvil
//
//  Created by Assistant on 28/8/25.
//

import SwiftUI

struct iPhone16Frame<Content: View>: View {
    let content: Content
    let isDarkMode: Bool
    @State private var currentTime = Date()
    
    // Timer to update time every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(isDarkMode: Bool = false, @ViewBuilder content: () -> Content) {
        self.isDarkMode = isDarkMode
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // iPhone 16 frame with dynamic island
            ZStack {
                // Main phone body
                RoundedRectangle(cornerRadius: 50)
                    .fill(phoneFrameColor)
                    .frame(width: 340, height: 720)
                    .overlay(
                        // Screen area
                        RoundedRectangle(cornerRadius: 42)
                            .fill(Color.black)
                            .frame(width: 320, height: 700)
                    )
                    .overlay(
                        // Content area with overlaid UI elements
                        ZStack {
                            // App content filling entire screen (behind UI elements)
                            content
                                .frame(width: 320, height: 700)
                                .clipped()
                            
                            // Overlay status bar and home indicator on top of content
                            VStack(spacing: 0) {
                                // Status bar area with dynamic island (overlaid on top)
                                statusBarWithDynamicIsland
                                    .frame(height: 54)
                                
                                Spacer()
                                
                                // Home indicator area (overlaid on bottom)
                                homeIndicatorArea
                                    .frame(height: 34)
                            }
                            .frame(width: 320, height: 700)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 42))
                    )
                
                // Side buttons
                sideButtons
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    // MARK: - Computed Properties
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: currentTime)
    }
    
    // MARK: - Phone Frame Color
    private var phoneFrameColor: Color {
        Color.black
    }
    
    // MARK: - Status Bar with Dynamic Island
    private var statusBarWithDynamicIsland: some View {
        ZStack {
            // Transparent background - let content show through
            Color.clear
            
            // Dynamic Island - positioned absolutely in center
            VStack {
                Spacer().frame(height: 8)
                dynamicIsland
                Spacer()
            }
            
            // Status items positioned around the dynamic island
            VStack(spacing: 0) {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    // Left status items with dynamic time and shadow for visibility
                    HStack(spacing: 4) {
                        Text(timeString)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(isDarkMode ? Color.white : Color.black)

                    }
                    
                    Spacer()
                    
                    // Space for dynamic island (invisible placeholder)
                    Color.clear
                        .frame(width: 126, height: 37)
                    
                    Spacer()
                    
                    // Right status items with shadow for visibility
                    HStack(spacing: 2) {
                        Text(Image(systemName: "cellularbars"))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(isDarkMode ? Color.white : Color.black)

                        Text(Image(systemName: "wifi"))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(isDarkMode ? Color.white : Color.black)

                        Text(Image(systemName: "battery.75percent"))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(isDarkMode ? Color.white : Color.black)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Dynamic Island
    private var dynamicIsland: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black)
            .frame(width: 126, height: 37)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
            .overlay(
                HStack(spacing: 8) {
                    // Camera indicator
                    Circle()
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: 6, height: 6)
                    
                    Spacer()
                    
                    // Face ID sensor area
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 12, height: 4)
                    
                    Spacer()
                    
                    // Additional sensor
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 4, height: 4)
                }
                .padding(.horizontal, 12)
            )
    }
    
    // MARK: - Home Indicator Area
    private var homeIndicatorArea: some View {
        ZStack {
            // Transparent background - let content show through
            Color.clear
            
            VStack {
                Spacer()
                
                // Home indicator with purple theme
                RoundedRectangle(cornerRadius: 2.5)
                    .fill((isDarkMode ? Color.white : Color.black).opacity(0.85))
                    .frame(width: 134, height: 5)
                    .shadow(color: (isDarkMode ? Color.black : Color.gray).opacity(0.3), radius: 1.5, x: 0, y: 0)
                    .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - Side Buttons
    private var sideButtons: some View {
        ZStack {
            // Action Button (left side, top - positioned higher with more spacing)
            RoundedRectangle(cornerRadius: 2)
                .fill(phoneFrameColor)
                .frame(width: 4, height: 32)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 0)
                .offset(x: -172, y: -200)
            
            // Volume Up button (left side, lower section - taller and higher)
            RoundedRectangle(cornerRadius: 2)
                .fill(phoneFrameColor)
                .frame(width: 4, height: 42)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 0)
                .offset(x: -172, y: -150)
            
            // Volume Down button (left side, below volume up - same size, taller and higher)
            RoundedRectangle(cornerRadius: 2)
                .fill(phoneFrameColor)
                .frame(width: 4, height: 42)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 0)
                .offset(x: -172, y: -100)
            
            // Power button (right side)
            RoundedRectangle(cornerRadius: 2)
                .fill(phoneFrameColor)
                .frame(width: 4, height: 65)
                .shadow(color: .black.opacity(0.2), radius: 1, x: -1, y: 0)
                .offset(x: 172, y: -165)
        }
    }
}

// MARK: - Preview
#Preview {
    iPhone16Frame(isDarkMode: false) {
        VStack {
            Text("Sample App Content")
                .font(.title)
                .foregroundColor(.primary)
            
            Spacer()
            
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .frame(height: 100)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.2))
                    .frame(height: 100)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.2))
                    .frame(height: 100)
            }
            .padding()
            
            Spacer()
        }
        .padding(.top, 50)
        .background(Color(.systemBackground))
    }
}
