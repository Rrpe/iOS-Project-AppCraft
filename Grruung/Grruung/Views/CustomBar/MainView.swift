//
//  MainView.swift
//  Grruung
//
//  Created by KimJunsoo on 6/10/25.
//

import SwiftUI

// MARK: - 메인 뷰
/// 앱의 메인 뷰로, 모든 탭 화면을 관리합니다
/// - 커스텀 탭바를 사용하여 화면 간 전환을 제공합니다
/// - 탭 내용은 전체 화면을 채우며, 탭바는 그 위에 떠 있습니다
struct MainView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var characterService: FirebaseService
    @StateObject private var tabBarController = CustomTabBarController()
    private var color: Color = GRColor.mainColor1_2
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 현재 선택된 탭에 따른 컨텐츠 표시
                TabContent(selectedTab: tabBarController.selectedTab)
                    .padding(.bottom, tabBarController.selectedTab == 0 || tabBarController.selectedTab == 1 ? 0 : 90)
                    .edgesIgnoringSafeArea(.all)
                
                if tabBarController.selectedTab != 0 {
                    switch tabBarController.selectedTab {
                    case 1:
                        Rectangle()
                            .fill(GRColor.mainColor1_2)
                            .frame(height: 81)
                            .ignoresSafeArea(edges: .bottom)
                    case 2:
                        Rectangle()
                            .fill(GRColor.mainColor2_2)
                            .frame(height: 90)
                            .ignoresSafeArea(edges: .bottom)
                    case 3:
                        Rectangle()
                            .fill(GRColor.mainColor1_2)
                            .frame(height: 90)
                            .ignoresSafeArea(edges: .bottom)
                    default:
                        Rectangle()
                            .fill(.white)
                            .frame(height: 90)
                            .ignoresSafeArea(edges: .bottom)
                    }
                }
                // 커스텀 탭바
                CustomTabBar(selectedTab: $tabBarController.selectedTab)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .edgesIgnoringSafeArea(.all)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - 탭 컨텐츠 뷰
/// 각 탭의 컨텐츠를 보여주는 뷰
/// - 선택된 탭 인덱스에 따라 다른 화면을 표시합니다
struct TabContent: View {
    let selectedTab: Int
    
    var body: some View {
        ZStack {
            // 각 탭에 해당하는 화면
            switch selectedTab {
            case 0:
                HomeView()
                    .edgesIgnoringSafeArea(.all)
            case 1:
                CharDexView()
                    .edgesIgnoringSafeArea(.all)
            case 2:
                StoreView()
                    .edgesIgnoringSafeArea(.all)
            case 3:
                MyPageView()
                    .edgesIgnoringSafeArea(.all)
            default:
                Text("Tab not found")
            }
        }
    }
}
