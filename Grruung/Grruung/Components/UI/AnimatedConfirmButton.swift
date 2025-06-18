//
//  AnimatedConfirmButton.swift
//  Grruung
//
//  Created by 심연아 on 5/7/25.
//

import SwiftUI

struct AnimatedConfirmButton: View {
    var onConfirm: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // 즉시 실행
            onConfirm()
        }) {
            Text("구매")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 130, height: 50)
                .background(
                    ZStack {
                        // 배경색 기본
                        GRColor.buttonColor_2
                        
                        // 윗부분 하이라이트 선
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                        
                        // 입체감용 위 blur
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                            .blur(radius: 2)
                            .offset(x: -2, y: -2)
                        
                        // 입체감용 아래 blur
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [GRColor.buttonColor_1,
                                             GRColor.buttonColor_2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(2)
                            .blur(radius: 2)
                            .offset(x: 2, y: 2)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(1.0)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

struct AnimatedCancelButton: View {
    var onCancel: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation {
                // 약간의 딜레이 넣음
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onCancel()
                }
            }
        }) {
            Text("취소")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 130, height: 50)
                .background(
                    ZStack {
                        // 배경색 기본
                        Color(red: 0.7, green: 0.7, blue: 0.7)
                        
                        // 윗부분 하이라이트 선
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                        
                        // 입체감용 위 blur
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.white)
                            .blur(radius: 2)
                            .offset(x: -2, y: -2)
                        
                        // 입체감용 아래 blur
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.75, green: 0.75, blue: 0.75),
                                             Color(red: 0.6, green: 0.6, blue: 0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(2)
                            .blur(radius: 2)
                            .offset(x: 2, y: 2)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(1.0)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
