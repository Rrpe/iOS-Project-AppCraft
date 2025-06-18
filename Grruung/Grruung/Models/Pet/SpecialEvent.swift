//
//  SpecialEvent.swift
//  Grruung
//
//  Created by KimJunsoo on 6/10/25.
//

import Foundation
import SwiftUI

// 특수 이벤트 모델
struct SpecialEvent: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let imageName: String
    let unlocked: Bool
    let requiredLevel: Int
    
    // 특수 이벤트가 제공하는 효과들
    let effects: [String: Int]
    
    // 활동 비용
    let activityCost: Int
    
    // 경험치 획득량
    let expGain: Int
    
    // 성공 메시지
    let successMessage: String
    
    // 실패 메시지
    let failMessage: String
}

// 특수 이벤트 관리자
class SpecialEventManager {
    // 싱글톤 인스턴스
    static let shared = SpecialEventManager()
    
    // 모든 특수 이벤트 목록
    private(set) var allEvents: [SpecialEvent] = []
    
    private init() {
        setupEvents()
    }
    
    // 이벤트 설정
    private func setupEvents() {
        allEvents = [
            SpecialEvent(
                id: "hot_spring",
                name: "온천여행",
                icon: "drop.fill",
                description: "온천에서 피로를 풀고 건강과 행복을 회복합니다.",
                imageName: "hot_spring_image",
                unlocked: true,
                requiredLevel: 10,
                effects: ["healthy": 20, "clean": 18, "happiness": 15, "stamina": 8],
                activityCost: 8,
                expGain: 7,
                successMessage: "온천에서 몸과 마음이 편안해졌어요!",
                failMessage: "온천에 갈 컨디션이 아니에요..."
            ),
            SpecialEvent(
                id: "camping",
                name: "캠핑가기",
                icon: "tent.fill",
                description: "자연 속에서 캠핑을 즐기며 특별한 추억을 만듭니다.",
                imageName: "camping_image",
                unlocked: true,
                requiredLevel: 15,
                effects: ["happiness": 25, "stamina": -10, "satiety": -8, "healthy": 5],
                activityCost: 12,
                expGain: 10,
                successMessage: "캠핑에서 자연과 함께하니 정말 좋아요!",
                failMessage: "캠핑갈 체력이 부족해요..."
            ),
            SpecialEvent(
                id: "amusement_park",
                name: "놀이공원",
                icon: "ferriswheel",
                description: "놀이공원에서 신나는 시간을 보냅니다.",
                imageName: "amusement_park_image",
                unlocked: false, // 잠금 상태
                requiredLevel: 20,
                effects: ["happiness": 30, "stamina": -15, "satiety": -10],
                activityCost: 15,
                expGain: 12,
                successMessage: "놀이공원은 정말 신나요! 최고에요!",
                failMessage: "놀이공원에 갈 기력이 없어요..."
            ),
            SpecialEvent(
                id: "beach",
                name: "해변여행",
                icon: "beach.umbrella.fill",
                description: "해변에서 수영도 하고 모래성도 쌓으며 즐거운 시간을 보냅니다.",
                imageName: "beach_image",
                unlocked: false, // 잠금 상태
                requiredLevel: 25,
                effects: ["happiness": 28, "stamina": -12, "clean": -5, "healthy": 8],
                activityCost: 14,
                expGain: 11,
                successMessage: "해변에서 수영하니 너무 즐거워요!",
                failMessage: "해변에 갈 컨디션이 아니에요..."
            ),
            SpecialEvent(
                id: "mountain_hiking",
                name: "등산하기",
                icon: "mountain.2.fill",
                description: "높은 산을 오르며 성취감과 건강을 동시에 얻습니다.",
                imageName: "mountain_hiking_image",
                unlocked: false, // 잠금 상태
                requiredLevel: 30,
                effects: ["healthy": 25, "stamina": -20, "satiety": -15, "happiness": 15],
                activityCost: 18,
                expGain: 15,
                successMessage: "산 정상에 올라 경치가 너무 멋져요!",
                failMessage: "등산할 체력이 부족해요..."
            )
        ]
    }
    
    // 레벨에 맞는 이벤트 가져오기
    func getAvailableEvents(level: Int) -> [SpecialEvent] {
        return allEvents.map { event in
            // 레벨 확인해서 잠금 상태 업데이트
            let isUnlocked = level >= event.requiredLevel
            
            if isUnlocked != event.unlocked {
                // 원본 이벤트 복사하고 잠금 상태만 변경
                return SpecialEvent(
                    id: event.id,
                    name: event.name,
                    icon: event.icon,
                    description: event.description,
                    imageName: event.imageName,
                    unlocked: isUnlocked,
                    requiredLevel: event.requiredLevel,
                    effects: event.effects,
                    activityCost: event.activityCost,
                    expGain: event.expGain,
                    successMessage: event.successMessage,
                    failMessage: event.failMessage
                )
            }
            
            return event
        }
    }
    
    // ID로 이벤트 찾기
    func getEvent(id: String) -> SpecialEvent? {
        return allEvents.first { $0.id == id }
    }
}
