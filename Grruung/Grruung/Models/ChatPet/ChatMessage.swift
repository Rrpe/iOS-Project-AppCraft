//
//  ChatModels.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//

import Foundation

// 펫과 나눈 대화 메시지 구조체
struct ChatMessage: Identifiable {
    let id: String = UUID().uuidString
    let text: String
    let isFromPet: Bool // true: 펫 메시지, false: 사용자 메시지
    let timestamp: Date
    
    init(text: String, isFromPet: Bool, timestamp: Date = Date()) {
        self.text = text
        self.isFromPet = isFromPet
        self.timestamp = timestamp
    }
}


