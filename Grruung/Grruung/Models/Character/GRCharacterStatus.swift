//
//  GRPetModels.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//  Created by mwpark on 5/7/25.
//

import Foundation

/// 캐릭터의 상태 정보를 담는 구조체
struct GRCharacterStatus {
    // MARK: - 유저에게 보이는 데이터
    /// 캐릭터의 현재 레벨
    /// - 0: 운석
    /// - 1~2: 유아기
    /// - 3~5: 소아기
    /// - 6~8: 청년기
    /// - 9~15: 성년기
    /// - 16~99: 노년기
    
    var level: Int // 현재 레벨
    var exp: Int // 현재 경험치
    var expToNextLevel: Int // 다음 레벨까지 남은 경험치
    var phase: CharacterPhase // 현재 시기
    var satiety: Int // 포만감 (0~100, 시작값 100)
    var stamina: Int // 운동량 (0~100, 시작값 100)
    var activity: Int // 활동량/피로도 (0~100, 시작값 100)
    var address: String // 거주지
    var birthDate: Date // 생일
    
    // MARK: - 유저에게 보이지 않는 데이터 (히든 스탯)
    var affection: Int // 누적 애정도 (0~1000, 시작값 0)
    var affectionCycle: Int // 주간 애정도 (0~100, 시작값 0)
    var healthy: Int // 건강도 (0~100, 시작값 50)
    var clean: Int // 청결도 (0~100, 시작값 50)
    var appearance: [String: String] // 외모 (성장 이후 바뀔 수 있음)
    var evolutionStatus: EvolutionStatus // 진화 상태
    
    // MARK: - 초기값
    init(level: Int = 0,
         exp: Int = 0,
         expToNextLevel: Int = 100,
         phase: CharacterPhase = .egg,
         satiety: Int = 100, // 시작값 100
         stamina: Int = 100, // 시작값 100
         activity: Int = 100, // 시작값 100
         affection: Int = 0, // 시작값 0
         affectionCycle: Int = 0, // 시작값 0
         healthy: Int = 50, // 시작값 50
         clean: Int = 50, // 시작값 50
         address: String = "userHome",
         birthDate: Date = Date(),
         appearance: [String: String] = [:],
         evolutionStatus: EvolutionStatus = .eggComplete) {
        
        self.level = level
        self.exp = exp
        self.expToNextLevel = expToNextLevel
        self.phase = phase
        self.satiety = satiety
        self.stamina = stamina
        self.activity = activity
        self.affection = affection
        self.affectionCycle = affectionCycle
        self.healthy = healthy
        self.clean = clean
        self.address = address
        self.birthDate = birthDate
        self.appearance = appearance
        self.evolutionStatus = evolutionStatus
    }
    
    // 캐릭터 성장 단계를 업데이트합니다.
    mutating func updatePhase() {
        switch level {
        case 0:
            phase = .egg
        case 1...2:
            phase = .infant
        case 3...5:
            phase = .child
        case 6...8:
            phase = .adolescent
        case 9...15:
            phase = .adult
        default:
            phase = .elder
        }
    }
    
    // 레벨업 시 호출되는 메서드
    mutating func levelUp() {
        level += 1
        exp = 0 // 경험치 초과분 이월 없이 0으로 초기화
        expToNextLevel = calculateNextLevelExp()
        updatePhase()
    }
    
    // 다음 레벨까지 필요한 경험치 계산
    private func calculateNextLevelExp() -> Int {
        return 100 + (level * 50) // 레벨이 올라갈수록 필요한 경험치 증가
    }
    
    // 상태 텍스트 반환
    func getStatusDescription() -> String {
        var status = ""
        
        if satiety < 30 {
            status += "배고픔 "
        }
        
        if stamina < 30 {
            status += "피곤함 "
        }
        
        if activity < 30 {
            status += "지침 "
        }
        
        if clean < 30 {
            status += "지저분함 "
        }
        
        if healthy < 30 {
            status += "아픔 "
        }
        
        if affection < 100 { // 애정도는 더 높은 기준 적용
            status += "외로움 "
        }
        
        if status.isEmpty {
            status = "행복함"
        }
        
        return status.trimmingCharacters(in: .whitespaces)
    }
}

// 펫 성장 단계 - Comparable 프로토콜 추가로 단계별 비교 가능하게 수정
enum CharacterPhase: String, Codable, Comparable, CaseIterable {
    case egg = "운석"
    case infant = "유아기"
    case child = "소아기"
    case adolescent = "청년기"
    case adult = "성년기"
    case elder = "노년기"
    
    // 성장 단계의 순서를 나타내는 수치 값
    // 이 값을 통해 단계별 비교가 가능합니다
    private var orderValue: Int {
        switch self {
        case .egg: return 0
        case .infant: return 1
        case .child: return 2
        case .adolescent: return 3
        case .adult: return 4
        case .elder: return 5
        }
    }
    
    // Comparable 프로토콜 구현
    // 성장 단계를 순서대로 비교할 수 있게 해줍니다
    static func < (lhs: CharacterPhase, rhs: CharacterPhase) -> Bool {
        return lhs.orderValue < rhs.orderValue
    }
    
    // 두 단계 사이의 차이를 계산합니다
    /// - Parameter other: 비교할 다른 단계
    /// - Returns: 단계 차이 (음수면 이전 단계, 양수면 이후 단계)
    func distanceTo(_ other: CharacterPhase) -> Int {
        return other.orderValue - self.orderValue
    }
    
    // 현재 단계가 특정 단계 이상인지 확인합니다
    /// - Parameter phase: 비교할 기준 단계
    /// - Returns: 기준 단계 이상이면 true
    func isAtLeast(_ phase: CharacterPhase) -> Bool {
        return self >= phase
    }
}

// 캐릭터 거주지 종류

enum Address: String, Codable, CaseIterable {
    case userHome = "userHome"
    case paradise = "paradise"
    case space = "space"
}

// MARK: - 진화 상태 열거형
enum EvolutionStatus: String, Codable, CaseIterable {
    case eggComplete = "eggComplete"          // 운석 단계 완료
    case toInfant = "toInfant"         // 유아기로 진화 중 (레벨 1 달성했지만 부화 진행 안함)
    case completeInfant = "completeInfant"     // 유아기 진화 완료 (부화 완료)
    case toChild = "toChild"          // 소아기로 진화 중
    case completeChild = "completeChild"      // 소아기 진화 완료
    case toAdolescent = "toAdolescent"     // 청년기로 진화 중
    case completeAdolescent = "completeAdolescent" // 청년기 진화 완료
    case toAdult = "toAdult"          // 성년기로 진화 중
    case completeAdult = "completeAdult"      // 성년기 진화 완료
    case toElder = "toElder"          // 노년기로 진화 중
    case completeElder = "completeElder"      // 노년기 진화 완료
    
    // 진화가 필요한 상태인지 확인
    var needsEvolution: Bool {
        switch self {
        case .toInfant, .toChild, .toAdolescent, .toAdult, .toElder:
            return true
        default:
            return false
        }
    }
    
    // 현재 상태에서 목표로 하는 성장 단계
    var targetPhase: CharacterPhase? {
        switch self {
        case .eggComplete:
            return .egg
        case .toInfant, .completeInfant:
            return .infant
        case .toChild, .completeChild:
            return .child
        case .toAdolescent, .completeAdolescent:
            return .adolescent
        case .toAdult, .completeAdult:
            return .adult
        case .toElder, .completeElder:
            return .elder
        }
    }
}
