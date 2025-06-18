//
//  PetAction.swift
//  Grruung
//
//  Created by KimJunsoo on 5/22/25.
//
// TODO: - icon을 추후 image로 변경할수도 있음.
//

import Foundation

// 펫 액션 정의 구조체
struct PetAction: Identifiable {
    let id: String // 고유 ID
    let icon: String // SF 심볼 이름
    let name: String // 액션 이름
    let unlockPhase: CharacterPhase // 해금되는 성장 단계
    let phaseExclusive: Bool // true이면 해당 성장 단계에서만 사용 가능
    let activityCost: Int // 활동량 소모
    let effects: [String: Int] // 효과 (스탯 이름: 변화량)
    let expGain: Int // 경험치 획득량
    let successMessage: String // 성공 메시지
    let failMessage: String // 실패 메시지 (활동량 부족 등)
    let timeRestriction: TimeRestriction? // 시간 제한 (선택)
    
    // 새로운 이름으로 액션을 복제합니다.
    func withUpdatedName(_ newName: String) -> PetAction {
        return PetAction(
            id: self.id,
            icon: self.icon,
            name: newName,
            unlockPhase: self.unlockPhase,
            phaseExclusive: self.phaseExclusive,
            activityCost: self.activityCost,
            effects: self.effects,
            expGain: self.expGain,
            successMessage: self.successMessage,
            failMessage: self.failMessage,
            timeRestriction: self.timeRestriction
        )
    }
}

// 시간 제한 구조체
struct TimeRestriction {
    let startHour: Int // 시작 시간 (0-23)
    let endHour: Int // 종료 시간 (0-23)
    let isInverted: Bool // true면 endHour부터 startHour까지 유효
    
    /// 현재 시간이 제한 범위 내에 있는지 확인
    func isTimeAllowed(hour: Int) -> Bool {
        if isInverted {
            // 예: 밤 22시부터 아침 6시까지 (22-23, 0-6)
            return hour >= startHour || hour < endHour
        } else {
            // 예: 아침 6시부터 저녁 20시까지 (6-20)
            return hour >= startHour && hour < endHour
        }
    }
}

// 액션의 UI 표현 구조체 (HomeViewModel에서 사용)
struct ActionButton {
    let icon: String
    let name: String
    let unlocked: Bool
    let actionId: String // 실행할 액션 ID
}
