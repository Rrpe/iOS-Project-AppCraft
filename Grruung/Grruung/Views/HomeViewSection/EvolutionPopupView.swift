//
//  EvolutionPopupView.swift
//  Grruung
//
//  Created by NoelMacMini on 6/2/25.
//

import SwiftUI

struct EvolutionPopupView: View {
    // 팝업 표시 여부를 부모 뷰에서 제어
    @Binding var isPresented: Bool
    
    // 부화 진행 여부를 부모 뷰에 전달
    let onEvolutionStart: () -> Void    // "부화" 버튼을 눌렀을 때 호출
    let onEvolutionDelay: () -> Void    // "보류" 버튼을 눌렀을 때 호출
    
    var body: some View {
        ZStack {
            // 배경 (반투명 검은색)
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    // 배경을 눌러도 팝업이 닫히지 않도록 함
                }
            
            // 팝업 내용
            VStack(spacing: 25) {
                // 제목
                Text("🥚 부화 준비 완료!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                // 설명 텍스트
                VStack(spacing: 10) {
                    Text("지금 알을 부화시킬 수 있습니다")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    Text("부화하면 귀여운 쿼카가 태어나요!")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                .multilineTextAlignment(.center)
                
                // 버튼들
                HStack(spacing: 20) {
                    // 보류 버튼
                    Button(action: {
                        onEvolutionDelay() // 보류 액션 실행
                        isPresented = false // 팝업 닫기
                    }) {
                        Text("보류")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.gray)
                            .frame(width: 100, height: 44)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(22)
                    }
                    
                    // 부화 버튼
                    Button(action: {
                        onEvolutionStart() // 부화 액션 실행
                        isPresented = false // 팝업 닫기
                    }) {
                        Text("부화")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 100, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(22)
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - 프리뷰
#Preview {
    struct EvolutionPopupViewPreview: View {
        @State private var showPopup = true
        
        var body: some View {
            ZStack {
                Color.green.opacity(0.3).ignoresSafeArea()
                
                VStack {
                    Text("배경 화면")
                        .font(.title)
                    
                    Button("팝업 표시") {
                        showPopup = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
            }
            .overlay {
                if showPopup {
                    EvolutionPopupView(
                        isPresented: $showPopup,
                        onEvolutionStart: {
                            print("🥚 부화 시작!")
                        },
                        onEvolutionDelay: {
                            print("⏸️ 부화 보류")
                        }
                    )
                }
            }
        }
    }
    
    return EvolutionPopupViewPreview()
}
