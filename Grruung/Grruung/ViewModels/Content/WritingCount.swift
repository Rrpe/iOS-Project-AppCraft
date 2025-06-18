//
//  WritingCount.swift
//  Grruung
//
//  Created by NO SEONGGYEONG on 5/27/25.
//

import Foundation
import FirebaseFirestore

struct WritingCount: Identifiable {
    var id: String // GRUser의 ID
    var dailyRewardCount: Int // 오늘 받은 보상 횟수 (최대 5)
    var lastResetDate: Date // 마지막으로 dailyRewardCount가 리셋된 날짜
    
    // 오늘의 남은 보상 횟수
    var remainingRewards: Int {
        return max(0, 5 - dailyRewardCount)
    }
    
    // 보상을 받을 수 있는지 확인
    var canGetReward: Bool {
        return remainingRewards > 0
    }
    
    // 새로운 날이 시작되었는지 확인하고 필요하면 dailyRewardCount 리셋
    mutating func checkAndResetDaily() {
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            dailyRewardCount = 0 // 하루가 지나면 보상 횟수 초기화
            lastResetDate = Date()
        }
    }
    
    // 글쓰기 시도 (항상 성공하지만, 보상은 조건부)
    // 반환값: (항상 true, 보상 획득 여부)
    mutating func tryWrite() -> (success: Bool, expReward: Bool) {
        checkAndResetDaily() // 날짜가 바뀌었는지 확인
        
        if canGetReward {
            // 보상 획득 가능
            dailyRewardCount += 1
            return (true, true)
        } else {
            // 보상 획득 불가능
            return (true, false)
        }
    }
    
    // 초기화 메서드
    init(id: String, dailyRewardCount: Int = 0, lastResetDate: Date = Date()) {
        self.id = id
        self.dailyRewardCount = dailyRewardCount
        self.lastResetDate = lastResetDate
    }
    
    // Firestore에 저장할 Dictionary 변환
    func toFirestoreData() -> [String: Any] {
        return [
            "dailyRewardCount": dailyRewardCount,
            "lastResetDate": Timestamp(date: lastResetDate)
        ]
    }
    
    // Firestore에서 불러오기
    static func fromFirestore(document: DocumentSnapshot) -> WritingCount? {
        guard let data = document.data() else { return nil }
        
        return WritingCount(
            id: document.documentID,
            dailyRewardCount: data["dailyRewardCount"] as? Int ?? 0,
            lastResetDate: (data["lastResetDate"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
