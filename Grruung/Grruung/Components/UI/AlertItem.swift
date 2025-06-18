//
//  AlertItem.swift
//  Grruung
//
//  Created by KimJunsoo on 5/14/25.
//

import Foundation

// 알림 아이템 (오류 표시용)
struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}
