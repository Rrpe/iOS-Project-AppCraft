//
//  ItemEffectApplier.swift
//  Grruung
//
//  Created by KimJunsoo on 6/12/25.
//

import Foundation
import SwiftUI

/// 아이템 효과 데이터 구조체
struct ItemEffect {
    // 기본 스탯 효과
    var satiety: Int = 0      // 포만감
    var stamina: Int = 0      // 체력
    var activity: Int = 0     // 활동량
    var health: Int = 0       // 건강
    var clean: Int = 0        // 청결도
    var exp: Int = 0          // 경험치
    
    // 모든 스탯에 영향 (전체 스탯 관리용)
    static func all(_ value: Int) -> ItemEffect {
        return ItemEffect(
            satiety: value,
            stamina: value,
            activity: value,
            health: value,
            clean: value,
            exp: value / 2    // 경험치는 일반적으로 적게 제공
        )
    }
    
    // 기존 효과를 수량에 맞게 조정
    func multiplied(by quantity: Int) -> ItemEffect {
        return ItemEffect(
            satiety: self.satiety * quantity,
            stamina: self.stamina * quantity,
            activity: self.activity * quantity,
            health: self.health * quantity,
            clean: self.clean * quantity,
            exp: self.exp * quantity
        )
    }
    
    // 효과 문자열 생성
    func getEffectDescription(quantity: Int = 1) -> String {
        var parts: [String] = []
        
        if satiety > 0 { parts.append("포만감 +\(satiety * quantity)") }
        if stamina > 0 { parts.append("체력 +\(stamina * quantity)") }
        if activity > 0 { parts.append("활동량 +\(activity * quantity)") }
        if health > 0 { parts.append("건강 +\(health * quantity)") }
        if clean > 0 { parts.append("청결도 +\(clean * quantity)") }
        if exp > 0 { parts.append("경험치 +\(exp * quantity)") }
        
        return parts.joined(separator: ", ")
    }
    
    // 효과 여부 확인
    var hasEffect: Bool {
        return satiety > 0 || stamina > 0 || activity > 0 || health > 0 || clean > 0 || exp > 0
    }
}

/// 아이템 효과를 펫에게 적용하는 서비스 클래스
class ItemEffectApplier {
    // MARK: - 싱글톤 및 프로퍼티
    
    /// 싱글톤 인스턴스
    static let shared = ItemEffectApplier()
    
    /// 홈 뷰 모델 참조
    private weak var homeViewModel: HomeViewModel?
    
    // MARK: - 아이템 효과 정의
    
    /// 특정 아이템별 효과 정의
    private var itemEffects: [String: ItemEffect] = [
        // 회복 아이템
        "아이스크림": ItemEffect(stamina: 10, health: 15),
        "햄버거": ItemEffect(satiety: 20, health: 5),
        "팬케이크": ItemEffect(stamina: 10, activity: 15),
        "복숭아 먹기": ItemEffect(stamina: 18, clean: 7),
        "배 먹기": ItemEffect(satiety: 12, health: 13),
        "수박 먹기": ItemEffect(satiety: 10, stamina: 15, clean: 5),
        "쉐이크": ItemEffect(satiety: 100, stamina: 100,activity: 100),
        "초밥 먹기": ItemEffect(satiety: 10, activity: 12, health: 8),
        "와플 먹기": ItemEffect(exp: 100),
        
        // 채팅 티켓 효과 추가
//        "채팅 티켓": ItemEffect(), // 특별한 스탯 효과 없음
        
        // 추가 아이템 효과는 여기에 간단히 추가 가능
    ]
    
    /// 카테고리별 기본 효과 정의
    private let categoryEffects: [ItemCategory: ItemEffect] = [
        .food: ItemEffect(satiety: 10),
        .drug: ItemEffect(health: 10, clean: 5),
        .toy: ItemEffect(stamina: 10, activity: 5, exp: 5),
        .etc: ItemEffect(satiety: 5, stamina: 5, activity: 5, health: 5, clean: 5, exp: 2)
    ]
    
    // MARK: - 초기화 및 설정
    
    private init() {}
    
    /// 홈 뷰 모델 설정
    /// - Parameter viewModel: HomeViewModel 인스턴스
    func setHomeViewModel(_ viewModel: HomeViewModel) {
        self.homeViewModel = viewModel
    }
    
    // MARK: - 효과 적용 메서드
    
    /// 아이템 효과를 펫에게 적용
    /// - Parameters:
    ///   - item: 사용할 아이템
    ///   - quantity: 사용할 수량
    /// - Returns: 효과 적용 성공 여부와 결과 메시지
    func applyItemEffect(item: GRUserInventory, quantity: Int) -> (success: Bool, message: String) {
        guard let homeViewModel = homeViewModel else {
            return (false, "펫 데이터를 찾을 수 없습니다.")
        }
        
        // 1. 특정 아이템에 정의된 효과 확인
        if let effect = itemEffects[item.userItemName] {
            return applyEffect(effect: effect, itemName: item.userItemName, quantity: quantity, homeViewModel: homeViewModel)
        }
        
        // 2. 카테고리별 기본 효과 적용
        if let effect = categoryEffects[item.userItemCategory] {
            return applyEffect(effect: effect, itemName: item.userItemName, quantity: quantity, homeViewModel: homeViewModel)
        }
        
        // 3. 기본 효과 적용 (정의되지 않은 아이템)
        let defaultEffect = ItemEffect.all(5)
        return applyEffect(effect: defaultEffect, itemName: item.userItemName, quantity: quantity, homeViewModel: homeViewModel)
    }
    
    // MARK: - 내부 헬퍼 메서드
    
    /// 효과 적용 메서드
    private func applyEffect(effect: ItemEffect, itemName: String, quantity: Int, homeViewModel: HomeViewModel) -> (Bool, String) {
        // 효과가 없는 경우
        if !effect.hasEffect {
            return (true, "\(itemName) 사용했지만 특별한 효과가 없었습니다.")
        }
        
        // 채팅 티켓인 경우 특별 처리
        if itemName == "채팅 티켓" {
            // 채팅 횟수 추가 (기존의 티켓 추가 대신)
            let newChatCount = ChatLimitManager.shared.addChatCount(3 * quantity) // 티켓 1개당 3회 추가
            return (true, "\(itemName) 사용 완료: 챗펫 대화 횟수 \(3 * quantity)회 추가되었습니다. (현재: \(newChatCount)회)")
        }

        // 포만감 증가
        if effect.satiety > 0 {
            homeViewModel.updateCharacterSatietyStatus(satietyValue: effect.satiety * quantity)
        }
        
        // 체력 증가
        if effect.stamina > 0 {
            homeViewModel.updateCharacterStaminaStatus(staminaValue: effect.stamina * quantity)
        }
        
        // 활동량 증가
        if effect.activity > 0 {
            homeViewModel.updateCharacterActivityStatus(activityValue: effect.activity * quantity)
        }
        
        // 건강 증가
        if effect.health > 0 {
            homeViewModel.updateCharacterHealthStatus(healthValue: effect.health * quantity)
        }
        
        // 청결도 증가
        if effect.clean > 0 {
            homeViewModel.updateCharacterCleanStatus(cleanValue: effect.clean * quantity)
        }
        
        // 경험치 증가 - NotificationCenter 활용
        if effect.exp > 0 {
            // 경험치 증가 알림 전송
            NotificationCenter.default.post(
                name: NSNotification.Name("AddExperiencePoints"),
                object: nil,
                userInfo: ["expPoints": effect.exp * quantity]
            )
        }
        
        let effectDescription = effect.getEffectDescription(quantity: quantity)
        return (true, "\(itemName) 사용 완료: \(effectDescription)")
    }
    
    // MARK: - 아이템 효과 관리 메서드
    
    /// 새 아이템 효과 추가 또는 기존 효과 업데이트
    /// - Parameters:
    ///   - itemName: 아이템 이름
    ///   - effect: 적용할 효과
    func registerItemEffect(itemName: String, effect: ItemEffect) {
        itemEffects[itemName] = effect
    }
    
    /// 여러 아이템 효과 한번에 등록
    /// - Parameter effects: [아이템 이름: 효과] 딕셔너리
    func registerMultipleEffects(_ effects: [String: ItemEffect]) {
        for (name, effect) in effects {
            itemEffects[name] = effect
        }
    }
    
    /// 아이템 효과 제거
    /// - Parameter itemName: 제거할 아이템 이름
    func removeItemEffect(itemName: String) {
        itemEffects.removeValue(forKey: itemName)
    }
    
    /// 특정 아이템의 효과 가져오기
    /// - Parameter itemName: 아이템 이름
    /// - Returns: 아이템 효과 또는 nil
    func getItemEffect(itemName: String) -> ItemEffect? {
        return itemEffects[itemName]
    }
}
