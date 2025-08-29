//
//  SignInView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 25/8/25.
//

import SwiftUI

struct SignInView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var isAnvilFloating = false
    @State private var isCoffeeFloating = false
    @State private var isGlassesFloating = false
    @State private var isLaptopFloating = false
    @State private var anvilRotationAngle: Double = -8
    @State private var coffeeRotationAngle: Double = 5
    @State private var glassesRotationAngle: Double = -3
    @State private var laptopRotationAngle: Double = 2
    @Environment((\.colorScheme)) var colorScheme
    
    var body: some View {
        VStack(spacing: 40) {
                Spacer()

                // App Logo/Title Section
                VStack(spacing: 20) {
                    Text("Anvil")
                        .monospaced()
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .fontWeight(.bold)

                }
                
                // Floating Assets Layout
                ZStack {
                    // Main Anvil in center
                    Image("AnvilFloating")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .rotationEffect(.degrees(anvilRotationAngle))
                        .offset(y: isAnvilFloating ? -8 : 8)
                        .animation(
                            Animation.easeInOut(duration: 2.8)
                                .repeatForever(autoreverses: true),
                            value: isAnvilFloating
                        )
                        .animation(
                            Animation.easeInOut(duration: 3.2)
                                .repeatForever(autoreverses: true),
                            value: anvilRotationAngle
                        )
                    
                    // Coffee floating top-left
                    Image("Coffee")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .rotationEffect(.degrees(coffeeRotationAngle))
                        .offset(
                            x: -80 + (isCoffeeFloating ? -5 : 5),
                            y: -60 + (isCoffeeFloating ? -8 : 8)
                        )
                        .animation(
                            Animation.easeInOut(duration: 3.1)
                                .repeatForever(autoreverses: true),
                            value: isCoffeeFloating
                        )
                        .animation(
                            Animation.easeInOut(duration: 2.7)
                                .repeatForever(autoreverses: true),
                            value: coffeeRotationAngle
                        )
                    
                    // Glasses floating top-right
                    Image("Glasses")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 45)
                        .rotationEffect(.degrees(glassesRotationAngle))
                        .offset(
                            x: 85 + (isGlassesFloating ? 5 : -5),
                            y: -50 + (isGlassesFloating ? -6 : 6)
                        )
                        .animation(
                            Animation.easeInOut(duration: 2.9)
                                .repeatForever(autoreverses: true),
                            value: isGlassesFloating
                        )
                        .animation(
                            Animation.easeInOut(duration: 3.5)
                                .repeatForever(autoreverses: true),
                            value: glassesRotationAngle
                        )
                    
                    // Laptop floating bottom
                    Image("Laptop")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 55)
                        .rotationEffect(.degrees(laptopRotationAngle))
                        .offset(
                            x: -10 + (isLaptopFloating ? -4 : 4),
                            y: 80 + (isLaptopFloating ? 6 : -6)
                        )
                        .animation(
                            Animation.easeInOut(duration: 3.4)
                                .repeatForever(autoreverses: true),
                            value: isLaptopFloating
                        )
                        .animation(
                            Animation.easeInOut(duration: 2.6)
                                .repeatForever(autoreverses: true),
                            value: laptopRotationAngle
                        )
                }
                .frame(height: 200)
                .onAppear {
                    // Start all floating animations with slight delays
                    isAnvilFloating = true
                    anvilRotationAngle = -2
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isCoffeeFloating = true
                        coffeeRotationAngle = 10
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isGlassesFloating = true
                        glassesRotationAngle = -8
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isLaptopFloating = true
                        laptopRotationAngle = 5
                    }
                }
                

                
                VerticalTextSlideShow()
                

                
//                Spacer()
                
                // Sign In Button Section
                VStack(spacing: 20) {
                    Button(action: {
                        authViewModel.signInWithGitHub()
                    }) {
                        HStack(spacing: 12) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image("github-dark")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            
                            Text(authViewModel.isLoading ? "Signing in..." : "Sign in with GitHub")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .disabled(authViewModel.isLoading)
                    .scaleEffect(authViewModel.isLoading ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: authViewModel.isLoading)
                    
                    // Error message
                    if let errorMessage = authViewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .monospaced()
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 32)
                
                
                // Footer
                VStack(spacing: 8) {
                    Text("By signing in, you agree to our terms of service")
                        .monospaced()
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Secure authentication powered by Firebase")
                        .monospaced()
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(colorScheme == .dark ? 0.1 : 0.3), 
                    Color.purple.opacity(colorScheme == .dark ? 0.1 : 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .animation(.easeInOut(duration: 0.3), value: authViewModel.errorMessage)
    }
}


struct VerticalTextSlideShow: View {
    let texts = [
        "Welcome to Anvil ⚒️",
        "The multi-tool for your coding journey.",
        "Light enough to carry anywhere, strong enough for any task",
        "No hiker leaves without a multi-tool",
        "So why code without one?",
        "Let's get coding!"
    ]
    
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

    var body: some View {
            ZStack {
                ForEach(texts.indices, id: \.self) { index in
                    if index == currentIndex {
                        Text(texts[index])
                            .monospaced()
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(height: 150)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                            .id(index)
                    }
                }
            }
            .animation(.easeInOut(duration: 1.0), value: currentIndex)
        .onReceive(timer) { _ in
            currentIndex = (currentIndex + 1) % texts.count
        }
    }
}



#Preview {
    SignInView(authViewModel: AuthViewModel())
}










