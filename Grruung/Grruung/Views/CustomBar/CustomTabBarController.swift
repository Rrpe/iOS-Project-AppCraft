//
//  CustomTabBarController.swift
//  Grruung
//
//  Created by KimJunsoo on 6/10/25.
//

import SwiftUI
import Combine

// MARK: - 탭바 컨트롤러
/// 탭바의 상태를 관리하는 클래스
/// - 선택된 탭 인덱스를 추적합니다
/// - 탭 간 전환 시 애니메이션을 관리합니다
class CustomTabBarController: ObservableObject {
    @Published var selectedTab: Int = 0
    
    // 탭 간 전환 메서드
    func switchTab(to index: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedTab = index
        }
    }
}
