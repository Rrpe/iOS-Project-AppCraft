//
//  CleaningEffect.swift
//  Grruung
//
//  Created by NoelMacMini on 6/2/25.
//

import SwiftUI

// 대각선 깨끗함 이펙트 컴포넌트
struct CleaningEffect: View {
    // 🎯 이펙트 제어를 위한 바인딩
    @Binding var isActive: Bool
    
    // 🎯 내부 상태 변수들
    @State private var cleaningProgress: CGFloat = 0.0
    @State private var sparkleOpacity: Double = 0.0
    @State private var cleaningWaveOffset: CGFloat = -200
    
    // 🎯 커스터마이징 가능한 프로퍼티들
    let duration: Double
    let colors: [Color]
    let sparkleCount: Int
    
    // 초기화 (기본값 포함)
    init(
        isActive: Binding<Bool>,
        duration: Double = 1.6,
        colors: [Color] = [.white, .cyan, .blue],
        sparkleCount: Int = 12
    ) {
        self._isActive = isActive
        self.duration = duration
        self.colors = colors
        self.sparkleCount = sparkleCount
    }
    
    var body: some View {
        ZStack {
            if isActive {
                // 대각선 클리닝 웨이브
                cleaningWave
                
                // 반짝이는 파티클들
                cleaningSparkles
                
                // 깨끗함 오버레이
                cleanlinessOverlay
            }
        }
        .clipped()
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                startCleaningAnimation()
            }
        }
    }
    
    // MARK: - 이펙트 컴포넌트들
    
    @ViewBuilder
    private var cleaningWave: some View {
        ZStack {
            // 메인 클리닝 라인
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            colors[0].opacity(0.8),
                            colors[1].opacity(0.6),
                            colors[2].opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 300, height: 8)
                .rotationEffect(.degrees(45))
                .offset(x: cleaningWaveOffset, y: cleaningWaveOffset * 0.5)
            
            // 보조 클리닝 라인들
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                colors[0].opacity(0.4),
                                colors[1].opacity(0.3),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 200, height: 3)
                    .rotationEffect(.degrees(45))
                    .offset(
                        x: cleaningWaveOffset + CGFloat(index * 15),
                        y: (cleaningWaveOffset + CGFloat(index * 15)) * 0.5
                    )
            }
        }
    }
    
    @ViewBuilder
    private var cleaningSparkles: some View {
        ForEach(0..<sparkleCount, id: \.self) { index in
            let xOffset = cleaningWaveOffset + CGFloat(index * 20)
            let yOffset = xOffset * 0.5
            
            Group {
                if index % 3 == 0 {
                    Text("✨")
                        .font(.title2)
                        .foregroundStyle(colors[0])
                } else if index % 3 == 1 {
                    Text("💎")
                        .font(.caption)
                        .foregroundStyle(colors[1])
                } else {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [colors[0], colors[1].opacity(0.3), .clear],
                                center: .center,
                                startRadius: 1,
                                endRadius: 5
                            )
                        )
                        .frame(width: 8, height: 8)
                }
            }
            .offset(x: xOffset, y: yOffset)
            .opacity(sparkleOpacity)
            .scaleEffect(0.8 + sin(cleaningProgress * .pi + Double(index)) * 0.3)
        }
    }
    
    @ViewBuilder
    private var cleanlinessOverlay: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        colors[0].opacity(0.1),
                        colors[1].opacity(0.05),
                        .clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 150
                )
            )
            .frame(width: 200, height: 200)
            .opacity(cleaningProgress * 0.8)
            .scaleEffect(1.0 + cleaningProgress * 0.2)
            .animation(.easeOut(duration: duration * 0.6), value: cleaningProgress)
    }
    
    // MARK: - 애니메이션 제어
    
    private func startCleaningAnimation() {
        // 초기화
        cleaningProgress = 0.0
        sparkleOpacity = 0.0
        cleaningWaveOffset = -200
        
        // 1단계: 클리닝 웨이브 (duration의 50%)
        withAnimation(.easeInOut(duration: duration * 0.5)) {
            cleaningWaveOffset = 200
            sparkleOpacity = 1.0
        }
        
        // 2단계: 깨끗함 효과 (duration의 31% 후 시작)
        withAnimation(.easeOut(duration: duration * 0.375).delay(duration * 0.31)) {
            cleaningProgress = 1.0
        }
        
        // 3단계: 반짝임 페이드 아웃 (duration의 62% 후)
        withAnimation(.easeIn(duration: duration * 0.25).delay(duration * 0.62)) {
            sparkleOpacity = 0.0
        }
        
        // 4단계: 전체 페이드 아웃 (duration의 81% 후)
        withAnimation(.easeIn(duration: duration * 0.19).delay(duration * 0.81)) {
            cleaningProgress = 0.0
        }
        
        // 정리
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.4) {
            isActive = false
        }
    }
}

// MARK: - 편의 메서드들

extension CleaningEffect {
    // 빠른 이펙트 (0.8초)
    static func quick(isActive: Binding<Bool>) -> CleaningEffect {
        CleaningEffect(isActive: isActive, duration: 0.8)
    }
    
    // 커스텀 색상 이펙트
    static func withColors(
        isActive: Binding<Bool>,
        colors: [Color]
    ) -> CleaningEffect {
        CleaningEffect(isActive: isActive, colors: colors)
    }
    
    // 강한 이펙트 (더 많은 파티클)
    static func intense(isActive: Binding<Bool>) -> CleaningEffect {
        CleaningEffect(
            isActive: isActive,
            duration: 2.0,
            sparkleCount: 20
        )
    }
}

// MARK: - 프리뷰

#Preview {
    struct CleaningEffectPreview: View {
        @State private var isActive = false
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .overlay(
                        CleaningEffect(isActive: $isActive)
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
    
    return CleaningEffectPreview()
}
