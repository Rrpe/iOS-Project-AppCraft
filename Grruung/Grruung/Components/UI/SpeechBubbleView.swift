//
//  SpeechBubbleView.swift
//  Grruung
//
//  Created by NoelMacMini on 6/13/25.
//

import SwiftUI

// MARK: - 말풍선 컴포넌트
struct SpeechBubbleView: View {
    let message: String
    let color: Color
    
    // 말풍선 표시 상태를 제어하는 상태 변수
    @State private var isVisible = true
    
    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    // 말풍선 배경
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.2), radius: 3)
                    
                    // 테두리
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.6), lineWidth: 1.5)
                    
                    // 말풍선 꼬리 부분
                    BubbleTriangle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 15, height: 10)
                        .overlay(
                            BubbleTriangle()
                                .stroke(color.opacity(0.6), lineWidth: 1.5)
                        )
                        .rotationEffect(.degrees(0))
                        .offset(y: 22)
                }
            )
            .opacity(isVisible ? 1 : 0)
            // onAppear 부분은 더 이상 필요하지 않음 (타이머는 ViewModel에서 처리)
    }
}

// 말풍선 꼬리 모양을 위한 삼각형 Shape
struct BubbleTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SpeechBubbleView(message: "테스트", color: .orange)
}
