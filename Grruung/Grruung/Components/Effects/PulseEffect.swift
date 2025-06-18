//
//  PulseEffect.swift
//  Grruung
//
//  Created by NoelMacMini on 6/2/25.
//

import SwiftUI

// 펄스 이펙트 컴포넌트
struct PulseEffect: View {
    @Binding var isActive: Bool
    
    @State private var scale: CGFloat = 0.0
    @State private var opacity: Double = 0.0
    
    let duration: Double
    let color: Color
    let maxScale: CGFloat
    
    init(
        isActive: Binding<Bool>,
        duration: Double = 0.8,
        color: Color = .yellow,
        maxScale: CGFloat = 2.0
    ) {
        self._isActive = isActive
        self.duration = duration
        self.color = color
        self.maxScale = maxScale
    }
    
    var body: some View {
        if isActive {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.8), color.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .opacity(opacity)
                .onChange(of: isActive) { oldValue, newValue in
                    if newValue {
                        startPulseAnimation()
                    }
                }
        }
    }
    
    private func startPulseAnimation() {
        scale = 0.0
        opacity = 0.0
        
        withAnimation(.easeOut(duration: duration)) {
            scale = maxScale
            opacity = 1.0
        }
        
        withAnimation(.easeIn(duration: duration * 0.3).delay(duration * 0.7)) {
            opacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
            isActive = false
        }
    }
}

// MARK: - 편의 메서드들

extension PulseEffect {
    static func heart(isActive: Binding<Bool>) -> PulseEffect {
        PulseEffect(isActive: isActive, color: .red, maxScale: 1.5)
    }
    
    static func healing(isActive: Binding<Bool>) -> PulseEffect {
        PulseEffect(isActive: isActive, color: .green, maxScale: 2.5)
    }
}

// MARK: - 프리뷰

#Preview {
    struct PulseEffectPreview: View {
        @State private var isActive = false
        
        var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .overlay(
                        PulseEffect(isActive: $isActive)
                    )
                
                VStack {
                    Spacer()
                    Button("이펙트 실행") {
                        isActive = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    return PulseEffectPreview()
}
