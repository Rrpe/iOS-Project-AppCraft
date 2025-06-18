//
//  ChatLimitManager.swift
//  Grruung
//
//  Created by KimJunsoo on 6/11/25.
//

import Foundation

// 채팅 제한 관리 클래스
class ChatLimitManager {
    static let shared = ChatLimitManager()
    
    // UserDefaults 키
    private enum UserDefaultsKeys {
        static let chatCountKey = "daily_chat_count"
        static let lastResetDateKey = "last_reset_date"
    }
    
    // 최대 무료 채팅 횟수
    let maxFreeChatCount = 3
    
    // 최대 누적 가능 채팅 횟수
    let maxChatCount = 99
    
    private init() {
        // 일일 초기화 확인
        checkAndResetDailyCount()
    }
    
    // 오늘 남은 채팅 횟수를 반환
    func getRemainingChats() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultsKeys.chatCountKey)
    }
    
    // 채팅 횟수 추가 (티켓 사용 시)
    func addChatCount(_ count: Int) -> Int {
        let currentCount = getRemainingChats()
        let newCount = min(maxChatCount, currentCount + count)
        UserDefaults.standard.set(newCount, forKey: UserDefaultsKeys.chatCountKey)
        return newCount
    }
    
    // 채팅 횟수 사용
    func useChat() -> Bool {
        let currentCount = getRemainingChats()
        
        // 사용 가능한 채팅 횟수가 없는 경우
        if currentCount <= 0 {
            return false
        }
        
        // 카운트 감소
        UserDefaults.standard.set(currentCount - 1, forKey: UserDefaultsKeys.chatCountKey)
        return true
    }
    
    // 날짜 변경 시 카운트 초기화 (최소 3으로)
    private func checkAndResetDailyCount() {
        let calendar = Calendar.current
        let now = Date()
        
        // 마지막 초기화 날짜 가져오기
        if let lastResetDateData = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastResetDateKey) as? Date {
            // 날짜가 변경되었는지 확인
            if !calendar.isDate(lastResetDateData, inSameDayAs: now) {
                // 날짜가 변경되었으면 초기화 (최소 3으로)
                let currentCount = getRemainingChats()
                let newCount = max(maxFreeChatCount, currentCount) // 현재 값이 3보다 크면 유지
                UserDefaults.standard.set(newCount, forKey: UserDefaultsKeys.chatCountKey)
                UserDefaults.standard.set(now, forKey: UserDefaultsKeys.lastResetDateKey)
            }
        } else {
            // 최초 사용 시 설정
            UserDefaults.standard.set(now, forKey: UserDefaultsKeys.lastResetDateKey)
            UserDefaults.standard.set(maxFreeChatCount, forKey: UserDefaultsKeys.chatCountKey)
        }
    }
}
