//
//  CustomBar.swift
//  Grruung
//
//  Created by KimJunsoo on 6/10/25.
//

import SwiftUI

// MARK: - 커스텀 탭바 구현
/// 앱 하단에 표시될 커스텀 탭바 뷰
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    
    // 탭 아이템 정의
    private let tabItems = [
        TabItem(icon: "house.fill", name: "홈"),
        TabItem(icon: "teddybear.fill", name: "캐릭터"),
        TabItem(icon: "cart.fill", name: "상점"),
        TabItem(icon: "person.circle.fill", name: "설정")
    ]
    
    // 탭바 배경색 (다크모드 대응)
    private var backgroundColor: Color {
        return colorScheme == .dark ? Color.black.opacity(0.8) : selectedTab != 0 ? Color.white.opacity(0.3) : Color.white.opacity(0.1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 0) {
                    // 각 탭 아이템을 가로로 배치
                    ForEach(0..<tabItems.count, id: \.self) { index in
                        let item = tabItems[index]
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                            }
                        } label: {
                            VStack(spacing: 4) {
                                // 아이콘
                                Image(systemName: item.icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(selectedTab == index ? .orange : .gray)
                                
                                // 이름
                                /*
                                Text(item.name)
                                    .font(.system(size: 12))
                                    .foregroundStyle(selectedTab == index ? .blue : .gray)
                                 */
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .padding(.bottom, 12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8 + geometry.safeAreaInsets.bottom) // 하단 SafeArea 고려
                .background(
                    // 탭바 배경
                    backgroundColor
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
                )
                .padding(.horizontal, 24)
            }
        }
        .frame(height: 90) // 탭바 높이 조정 (기본 높이 + 하단 SafeArea 여유 공간)
    }
}

// 탭 아이템 모델
struct TabItem {
    var icon: String
    var name: String
}
