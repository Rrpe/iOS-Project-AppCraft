//
//  ContentView.swift
//  Grruung
//
//  Created by NoelMacMini on 4/30/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var characterDexViewModel: CharacterDexViewModel
    @State private var showOnboarding = false
    @State private var isFirstLogin = false
    
    var body: some View {
        Group {
            if authService.authenticationState == .authenticated {
                if isFirstLogin {
                    // 첫 로그인 시 온보딩 화면 표시
                    OnboardingView()
                } else {
                    // 로그인된 상태 = 홈 화면 표시
//                    MainTabView()
                    MainView()
                }
            } else {
                // 비로그인 상태 = 로그인 화면 표시
                LoginView()
            }
        }
        .onAppear {
            Task {
                // 앱 시작 시 자동으로 로그인 상태 확인
                authService.checkAuthState()
                
                // UID가 세팅됐다고 가정하고 사용
                if authService.currentUserUID != "" {
                    await characterDexViewModel.initialize(userId: authService.currentUserUID)
                } else {
                    print("❌ 로그인된 사용자 없음, 동산뷰 초기화 안 됨")
                }
            }
        }
        .onChange(of: authService.authenticationState) { oldState, newState in
            if oldState == .unauthenticated && newState == .authenticated {
                // 로그인 성공 시
                if let userId = authService.user?.uid {
                    print("로그인 \(Bool(!userId.isEmpty) ? "성공" : "실패")")
                    // 첫 로그인인지 확인
                    checkIfFirstLogin(userId: userId)
                }
            } else if oldState == .authenticated && newState == .unauthenticated {
                // 로그아웃 시
                isFirstLogin = false
            }
        }
    }
    
    // 첫 로그인인지 확인하는 함수
    private func checkIfFirstLogin(userId: String) {
        FirebaseService.shared.findCharactersByAddress(address: "userHome") { characters, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 캐릭터 조회 실패: \(error.localizedDescription)")
                    return
                }
                
                // 캐릭터가 없으면 첫 로그인으로 판단
                if let characters = characters, characters.isEmpty {
                    isFirstLogin = true
                } else {
                    isFirstLogin = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
