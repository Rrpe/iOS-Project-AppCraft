//
//  OnboardingView.swift
//  Grruung
//
//  Created by KimJunsoo on 6/2/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showNameSelection = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authService: AuthService
    
    // 온보딩 스토리 데이터
    let storyPages: [StoryPage] = [
        StoryPage(
            image: "intro1",
            title: "어느 평범한 날",
            description: "당신이 평소처럼 지내던 어느 날...",
            dialogue: "오늘도 평범한 하루가 시작되었어요."
        ),
        StoryPage(
            image: "intro2",
            title: "갑작스러운 소리",
            description: "갑자기 하늘에서 이상한 소리가 들렸어요!",
            dialogue: "우르릉... 쾅!! 무슨 소리지?!"
        ),
        StoryPage(
            image: "intro3",
            title: "떨어진 운석",
            description: "당신의 앞에 작은 운석이 떨어졌어요.",
            dialogue: "이게 뭐지? 우주에서 온 돌덩이인가?"
        ),
        StoryPage(
            image: "intro4",
            title: "신비로운 발견",
            description: "운석 안에서 무언가 움직이는 것 같아요!",
            dialogue: "어? 이게... 움직이고 있어? 뭔가 살아있는 것 같은데..."
        ),
        StoryPage(
            image: "intro5",
            title: "새로운 친구",
            description: "운석에서 신비로운 생명체가 나왔어요.",
            dialogue: "안녕? 넌 누구니? 우주에서 온 친구인가 보구나!"
        ),
        StoryPage(
            image: "intro6",
            title: "함께 시작하는 여정",
            description: "이제 이 신비로운 친구와 함께 성장하는 여정을 시작해보세요!",
            dialogue: "이제부터 우리 함께 지내자! 먼저 네 이름을 지어줄게."
        )
    ]
    
    var body: some View {
        ZStack {
            // 배경색
            LinearGradient(
                colors: [Color(hex: "FFF6EE"), Color(hex: "FDE0CA")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showNameSelection {
                // 이름 설정 화면
                PetNameSelectionView(onComplete: {
                    dismiss()
                })
                .transition(.opacity)
            } else {
                // 온보딩 스토리 화면
                VStack {
                    // 상단 건너뛰기 버튼
                    HStack {
                        Spacer()
                        Button("건너뛰기") {
                            withAnimation {
                                showNameSelection = true
                            }
                        }
                        .padding()
                        .foregroundStyle(.black)
                    }
                    
                    // 현재 페이지 이미지
                    Image(storyPages[currentPage].image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 300, height: 300)
                        )
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // 현재 페이지 텍스트
                    VStack {
                        Text(storyPages[currentPage].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        
                        Text(storyPages[currentPage].description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 5)
                        
                        // 대화 말풍선
                        Text(storyPages[currentPage].dialogue)
                            .font(.system(.body, design: .rounded))
                            .italic()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(colors: [Color(hex: "#FFB778"), Color(hex: "FFA04D")], startPoint: .leading, endPoint: .trailing)
                                    )
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .foregroundStyle(.white)
                    }
                    .frame(maxHeight: 200)
                    
                    Spacer()
                    
                    // 페이지 인디케이터
                    HStack(spacing: 8) {
                        ForEach(0..<storyPages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // 클릭 안내 텍스트
                    Text("화면을 탭하여 계속하기")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.bottom, 20)
                }
                .contentShape(Rectangle()) // 전체 영역을 탭 가능하게
                .onTapGesture {
                    // 다음 페이지로 이동 또는 이름 설정 화면으로 전환
                    withAnimation {
                        if currentPage < storyPages.count - 1 {
                            currentPage += 1
                        } else {
                            showNameSelection = true
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// 스토리 페이지 모델
struct StoryPage {
    let image: String
    let title: String
    let description: String
    let dialogue: String
}

#Preview {
    OnboardingView()
}
