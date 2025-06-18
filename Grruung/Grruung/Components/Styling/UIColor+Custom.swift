//
//  UIColor+Custom.swift
//  Grruung
//
//  Created by KimJunsoo on 6/4/25.
//

import SwiftUI

/// 앱에서 사용하는 색상을 한 곳에서 관리 (HIG 기반 권장 컬러 예시)
extension Color {
    static let primaryMain = Color("PrimaryMain") // Asset에서 등록 or 직접 코드
    static let secondaryMain = Color("SecondaryMain")
    static let background = Color("Background")
    static let accent = Color("Accent")
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    // ... 기타 색상
}
