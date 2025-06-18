//
//  SparkleEffect.swift
//  Grruung
//
//  Created by NoelMacMini on 6/2/25.
//

import SwiftUI

import SwiftUI

// 반짝이는 이펙트 컴포넌트
struct SparkleEffect: View {
    @Binding var isActive: Bool
    
    // 내부 상태
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = 0.0
    
    // 커스터마이징 프로퍼티
    let duration: Double
    let sparkleCount: Int
    let colors: [Color]
    
    init(
        isActive: Binding<Bool>,
        duration: Double = 1.0,
        sparkleCount: Int = 8,
        colors: [Color] = [.yellow, .orange, .white]
    ) {
        self._isActive = isActive
        self.duration = duration
        self.sparkleCount = sparkleCount
        self.colors = colors
    }
    
    var body: some View {
        ZStack {
            if isActive {
                // 중앙 빛나는 원
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // 반짝이는 파티클들
                ForEach(0..<sparkleCount, id: \.self) { index in
                    sparkleParticle(index: index)
                }
            }
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                startSparkleAnimation()
            }
        }
    }
    
    @ViewBuilder
    private func sparkleParticle(index: Int) -> some View {
        let angle = Double(index) * (360.0 / Double(sparkleCount))
        let distance: CGFloat = 50
        
        Text("✨")
            .font(.title2)
            .foregroundStyle(colors.randomElement() ?? .yellow)
            .offset(
                x: cos(angle * .pi / 180) * distance,
                y: sin(angle * .pi / 180) * distance
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .animation(
                .easeOut(duration: duration * 0.6).delay(Double(index) * 0.1),
                value: scale
            )
    }
    
    private func startSparkleAnimation() {
        // 초기화
        scale = 0.5
        opacity = 0.0
        rotation = 0.0
        
        // 애니메이션 실행
        withAnimation(.easeOut(duration: duration * 0.6)) {
            scale = 1.5
            opacity = 1.0
            rotation = 360
        }
        
        // 페이드 아웃
        withAnimation(.easeIn(duration: duration * 0.4).delay(duration * 0.6)) {
            opacity = 0.0
            scale = 2.0
        }
        
        // 정리
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.2) {
            isActive = false
        }
    }
}

// MARK: - 편의 메서드들

extension SparkleEffect {
    static func magical(isActive: Binding<Bool>) -> SparkleEffect {
        SparkleEffect(
            isActive: isActive,
            duration: 1.5,
            sparkleCount: 12,
            colors: [.purple, .blue, .cyan, .white]
        )
    }
    
    static func golden(isActive: Binding<Bool>) -> SparkleEffect {
        SparkleEffect(
            isActive: isActive,
            colors: [.yellow, .orange, .red]
        )
    }
}


#Preview {
    struct SparkleEffectPreview: View {
        @State private var isActive = false
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .overlay(
                        SparkleEffect(isActive: $isActive)
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
    
    return SparkleEffectPreview()
}
