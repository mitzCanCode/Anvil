//
//  ShimmerEffect.swift
//  Anvil
//
//  Shimmer loading effect for skeleton views
//

import SwiftUI

// MARK: - Shimmer Effect Modifier

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = -200
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    content
                        .mask(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.4),
                                    .white.opacity(0.8),
                                    .white.opacity(0.4),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .scaleEffect(x: 2.5, y: 1)
                            .offset(x: phase)
                        )
                        .blendMode(.overlay)
                }
            )
            .onAppear {
                let width = UIScreen.main.bounds.width
                let animation = Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                
                withAnimation(animation) {
                    phase = width + 200
                }
            }
    }
}

// MARK: - View Extension

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Improved Shimmer with Shape Respect and Smooth Animation

struct CustomShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = -200
    let duration: Double
    let highlight: Color
    
    init(duration: Double = 1.5, highlight: Color = .white.opacity(0.6)) {
        self.duration = duration
        self.highlight = highlight
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    content
                        .mask(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    highlight.opacity(0.3),
                                    highlight.opacity(0.8),
                                    highlight.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .scaleEffect(x: 2.5, y: 1)
                            .offset(x: phase)
                        )
                        .blendMode(.overlay)
                }
            )
            .onAppear {
                let width = UIScreen.main.bounds.width
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = width + 200
                }
            }
    }
}

extension View {
    func shimmer(duration: Double = 1.5, highlight: Color = .white.opacity(0.6)) -> some View {
        modifier(CustomShimmerEffect(duration: duration, highlight: highlight))
    }
}
