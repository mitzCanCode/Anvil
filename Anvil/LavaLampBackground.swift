//
//  LavaLampBackground.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 2/10/25.
//


import SwiftUI

struct LavaLampBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        TimelineView(.animation) { timeline in
            let currentTime = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                // Brighter blue/purple tones
                let baseBlue = Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.4)
                let basePurple = Color.purple.opacity(colorScheme == .dark ? 0.3 : 0.5)

                // More blobs (from 7 → 14)
                for i in 0..<14 {
                    let speed = Double(i + 1) * 0.12
                    let x = cos(currentTime * speed + Double(i)) * size.width * 0.25
                    let y = sin(currentTime * speed * 0.7 + Double(i)) * size.height * 0.25

                    let centerX = size.width / 2 + x + dragOffset.width / 6
                    let centerY = size.height / 2 + y + dragOffset.height / 6

                    let baseSize: CGFloat = CGFloat(150 + (i % 4) * 40) // a bit more variety
                    let wobbleX = sin(currentTime * 0.9 + Double(i)) * 35
                    let wobbleY = cos(currentTime * 1.1 + Double(i)) * 35
                    let width = baseSize + CGFloat(wobbleX)
                    let height = baseSize + CGFloat(wobbleY)

                    let blobRect = CGRect(
                        x: centerX - width / 2,
                        y: centerY - height / 2,
                        width: width,
                        height: height
                    )

                    var blob = Path()
                    blob.addEllipse(in: blobRect)

                    // Stronger gradient for more glow
                    let gradient = Gradient(colors: [baseBlue, basePurple])
                    let shading = GraphicsContext.Shading.radialGradient(
                        gradient,
                        center: .init(x: blobRect.midX, y: blobRect.midY),
                        startRadius: 0,
                        endRadius: width * 0.7
                    )

                    context.fill(blob, with: shading)
                }
            }
            .blur(radius: 80) // slightly sharper glow
            .blendMode(.plusLighter)
        }
        .brightness(0.15)
        .scaleEffect(1.05)
    }
}

extension View {
    func customViewBackground() -> some View {
        self.background(
            LavaLampBackground()
                .ignoresSafeArea()
        )
    }
}


#Preview {
    LavaLampBackground()
        .ignoresSafeArea()
}
