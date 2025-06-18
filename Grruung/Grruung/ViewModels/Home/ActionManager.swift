//
//  ActionManager.swift
//  Grruung
//
//  Created by KimJunsoo on 5/22/25.
//

import Foundation

// 펫 액션 관리를 위한 클래스
class ActionManager {
    // 사용 가능한 모든 액션 목록
    private(set) var allActions: [PetAction] = []
    
    static let shared = ActionManager()
    
    private init() {
        setupActions()
    }
    
    // 현재 성장 단계에서 사용 가능한 액션 목록 가져오기
    /// - Parameters:
    ///   - phase: 현재 캐릭터의 성장 단계
    ///   - isSleeping: 캐릭터가 잠자고 있는 상태인지 여부
    /// - Returns: 사용 가능한 액션 배열
    func getAvailableActions(phase: CharacterPhase, isSleeping: Bool) -> [PetAction] {
        // 자는 상태에서는 깨우기(재우기) 액션만 사용 가능
        if isSleeping {
            return allActions.filter { $0.id == "sleep" }
        }
        
        // 현재 성장 단계에서 사용 가능한 액션만 필터링
        return allActions.filter { action in
            if action.phaseExclusive {
                // 단계 전용 액션인 경우: 정확히 해당 단계에서만 사용 가능
                return action.unlockPhase == phase
            } else {
                // 일반 액션인 경우: 해당 단계 이상에서 사용 가능
                return phase.isAtLeast(action.unlockPhase)
            }
        }
    }
    
    // 시간대에 맞는 액션 목록 가져오기
    /// - Parameters:
    ///   - actions: 필터링할 액션 배열
    ///   - hour: 현재 시간 (0-23)
    /// - Returns: 시간 제한을 통과한 액션 배열
    func getTimeFilteredActions(actions: [PetAction], hour: Int) -> [PetAction] {
        return actions.filter { action in
            // 시간 제한이 없으면 항상 표시
            guard let restriction = action.timeRestriction else { return true }
            return restriction.isTimeAllowed(hour: hour)
        }
    }
    
    // 현재 시간, 성장 단계에 맞는 액션 버튼 목록 가져오기
    /// - Parameters:
    ///   - phase: 현재 캐릭터의 성장 단계
    ///   - isSleeping: 캐릭터가 잠자고 있는 상태인지 여부
    ///   - count: 반환할 액션 버튼의 개수 (기본값: 4)
    /// - Returns: 화면에 표시할 액션 버튼 배열
    func getActionsButtons(phase: CharacterPhase, isSleeping: Bool, count: Int = 4) -> [ActionButton] {
        // 현재 시간
        let hour = Calendar.current.component(.hour, from: Date())
        
        // 1단계: 성장 단계에 맞는 액션 필터링
        var availableActions = getAvailableActions(phase: phase, isSleeping: false)
        
        // 2단계: 시간 필터링 (자는 상태가 아닐 때만)
        if !isSleeping {
            availableActions = getTimeFilteredActions(actions: availableActions, hour: hour)
        }
        
        // 3단계: 결과 액션 목록 구성
        var result: [PetAction] = []
        
        // 재우기/깨우기 액션 처리 (항상 표시)
        if let sleepAction = allActions.first(where: { $0.id == "sleep" }) {
            // 자고 있는 경우 깨우기 액션으로 변경
            let modifiedSleepAction = isSleeping ?
                sleepAction.withUpdatedName("깨우기") : sleepAction
            result.append(modifiedSleepAction)
        }
        
        // 유아기에는 우유먹기 액션을 항상 표시
        if phase == .infant && !isSleeping {
            if let milkAction = allActions.first(where: { $0.id == "milk_feeding" }) {
                result.append(milkAction)
            }
        }
        
        // 4단계: 나머지 액션 랜덤하게 추가
        if !isSleeping {
            let otherActions = availableActions.filter { $0.id != "sleep" && $0.id != "milk_feeding" }
            
            // 운석 단계에서는 운석 전용 액션만 표시
            let finalActions: [PetAction]
            if phase == .egg {
                finalActions = otherActions.filter { $0.phaseExclusive && $0.unlockPhase == .egg }
            } else {
                finalActions = otherActions
            }
            
            // 남은 슬롯 수 계산
            let remainingSlots = count - result.count
            // 남은 슬롯이 있을 때만 랜덤 액션 추가
            if remainingSlots > 0 {
                let randomActions = finalActions.shuffled().prefix(remainingSlots)
                result.append(contentsOf: randomActions)
            }
            
    #if DEBUG
            print("🎯 액션 필터링 결과:")
            print("   - 현재 단계: \(phase.rawValue)")
            print("   - 전체 가능한 액션: \(availableActions.count)개")
            print("   - 최종 선택된 액션: \(result.map { $0.name }.joined(separator: ", "))")
    #endif
        }
        
        // ActionButton으로 변환
        return result.map { action in
            ActionButton(
                icon: action.icon,
                name: action.name,
                unlocked: true,
                actionId: action.id
            )
        }
    }
    
    // ID로 액션 찾기
    func getAction(id: String) -> PetAction? {
        return allActions.first { $0.id == id }
    }
    
    
    // 기본 액션 설정
    private func setupActions() {
        allActions = [
            // 운석 전용 액션
            // phaseExclusive = true시 그 단계에서만 사용가능한 활동 액션 등장
            PetAction(
                id: "tap_egg",
                icon: "Hands002Icon",
                name: "두드리기",
                unlockPhase: .egg,
                phaseExclusive: true, // 운석 단계에서만 사용 가능
                activityCost: 1,
                effects: ["stamina": 0], // 실제 스탯 변화 없음
                expGain: 5, // 많은 경험치 획득 (빠른 부화를 위해)
                successMessage: "두드리니 안에서 무언가 움직이는 것 같아요!",
                failMessage: "더 이상 반응이 없어요...",
                timeRestriction: nil
            ),
            PetAction(
                id: "warm_egg",
                icon: "fireIcon",
                name: "따뜻하게",
                unlockPhase: .egg,
                phaseExclusive: true, // 운석 단계에서만 사용 가능
                activityCost: 2,
                effects: ["stamina": 0], // 실제 스탯 변화 없음
                expGain: 7, // 많은 경험치 획득 (빠른 부화를 위해)
                successMessage: "알이 따뜻해지니 기분이 좋아보여요!",
                failMessage: "더 이상 반응이 없어요...",
                timeRestriction: nil
            ),
            PetAction(
                id: "talk_egg",
                icon: "chatIcon",
                name: "말걸기",
                unlockPhase: .egg,
                phaseExclusive: true, // 운석 단계에서만 사용 가능
                activityCost: 1,
                effects: ["stamina": 0], // 실제 스탯 변화 없음
                expGain: 4, // 많은 경험치 획득 (빠른 부화를 위해)
                successMessage: "알이 살짝 흔들리는 것 같아요!",
                failMessage: "더 이상 반응이 없어요...",
                timeRestriction: nil
            ),
            
            // 모든 단계 공통 액션
            PetAction(
                id: "sleep",
                icon: "nightIcon",
                name: "재우기",
                unlockPhase: .egg, // 모든 단계에서 사용 가능
                phaseExclusive: false,
                activityCost: 0, // 활동량 소모 없음
                effects: ["stamina": 10],
                expGain: 1,
                successMessage: "쿨쿨... 잠을 자고 있어요.",
                failMessage: "",
                timeRestriction: TimeRestriction(startHour: 22, endHour: 6, isInverted: true)
            ),
            
            // 우유먹기 (유아기 필수 액션)
            PetAction(
                id: "milk_feeding",
                icon: "milkIcon",
                name: "우유먹기",
                unlockPhase: .infant,
                phaseExclusive: true, // 유아기에만 사용 가능하도록 변경
                activityCost: 4,
                effects: ["satiety": 12, "healthy": 8, "happiness": 5],
                expGain: 4,
                successMessage: "우유가 맛있어요! 쑥쑥 자랄 수 있을 것 같아요!",
                failMessage: "지금은 우유를 먹고 싶지 않아요...",
                timeRestriction: nil
            ),
            
            // 유아기 이상 액션
            PetAction(
                id: "feed",
                icon: "appleIcon",
                name: "밥주기",
                unlockPhase: .infant, // 유아기부터 사용 가능
                phaseExclusive: false,
                activityCost: 5,
                effects: ["satiety": 15, "stamina": 5, "happiness": 3],
                expGain: 3,
                successMessage: "냠냠! 맛있어요!",
                failMessage: "너무 지쳐서 먹을 힘도 없어요...",
                timeRestriction: nil
            ),
            PetAction(
                id: "play",
                icon: "playIcon",
                name: "놀아주기",
                unlockPhase: .infant, // 유아기부터 사용 가능
                phaseExclusive: false,
                activityCost: 10,
                effects: ["happiness": 12, "stamina": -8, "satiety": -5],
                expGain: 5,
                successMessage: "우와! 너무 재밌어요!",
                failMessage: "너무 지쳐서 놀 수 없어요...",
                timeRestriction: nil
            ),
            PetAction(
                id: "wash",
                icon: "soapIcon",
                name: "씻기기",
                unlockPhase: .infant, // 유아기부터 사용 가능
                phaseExclusive: false,
                activityCost: 7,
                effects: ["clean": 15, "healthy": 5, "happiness": 2, "stamina": -3],
                expGain: 4,
                successMessage: "깨끗해져서 기분이 좋아요!",
                failMessage: "너무 지쳐서 씻기 힘들어요...",
                timeRestriction: nil
            ),
            
            
            // MARK: - 기타 관련 액션들
            PetAction(
                id: "weather_sunny",
                icon: "sunIcon",
                name: "햇살 즐기기",
                unlockPhase: .infant,
                phaseExclusive: false,
                activityCost: 5, // 날씨는 활동량 소모 없음
                effects: ["happiness": 8, "stamina": 3],
                expGain: 2,
                successMessage: "좋은 날씨에 기분이 좋아져요!",
                failMessage: "",
                timeRestriction: TimeRestriction(startHour: 6, endHour: 18, isInverted: false) // 낮 시간만
            ),
            
            PetAction(
                id: "walk_together",
                icon: "walking",
                name: "같이 걷기",
                unlockPhase: .child,
                phaseExclusive: false,
                activityCost: 12,
                effects: ["happiness": 15, "healthy": 10, "stamina": -6, "satiety": -8],
                expGain: 6,
                successMessage: "함께 산책하니 정말 즐거워요!",
                failMessage: "너무 지쳐서 산책할 힘이 없어요...",
                timeRestriction: nil
            ),
            
            PetAction(
                id: "rest_together",
                icon: "healing",
                name: "같이 쉬기",
                unlockPhase: .infant,
                phaseExclusive: false,
                activityCost: 0,
                effects: ["stamina": 12, "happiness": 8],
                expGain: 3,
                successMessage: "함께 쉬니까 편안해요!",
                failMessage: "",
                timeRestriction: nil
            ),
            
            // MARK: - 장소 관련 액션들
            PetAction(
                id: "secret_hideout",
                icon: "homeIcon",
                name: "비밀 아지트에서 놀기",
                unlockPhase: .infant,
                phaseExclusive: false,
                activityCost: 5,
                effects: ["happiness": 10, "stamina": 5, "clean": 3],
                expGain: 2,
                successMessage: "아지트에서 조용히 쉬고 있어요!",
                failMessage: "아지트에 가고 싶지 않은 기분이에요...",
                timeRestriction: nil
            ),
            
            // MARK: - 감정 관리 액션들
            PetAction(
                id: "comfort",
                icon: "loveHeartIcon",
                name: "달래주기",
                unlockPhase: .infant,
                phaseExclusive: false,
                activityCost: 3,
                effects: ["happiness": 15, "stamina": 2],
                expGain: 4,
                successMessage: "달래주니까 기분이 좋아져요!",
                failMessage: "너무 지쳐서 달래기 어려워요...",
                timeRestriction: nil
            ),
            
            PetAction(
                id: "encourage",
                icon: "Hands005Icon",
                name: "응원하기",
                unlockPhase: .child,
                phaseExclusive: false,
                activityCost: 4,
                effects: ["happiness": 18, "stamina": 5],
                expGain: 5,
                successMessage: "응원해주니까 힘이 나요!",
                failMessage: "너무 지쳐서 응원받을 기력이 없어요...",
                timeRestriction: nil
            ),
            
            // MARK: - 청결 관리 액션들 (확장)
            PetAction(
                id: "brush_fur",
                icon: "bathingIcon",
                name: "털빗기",
                unlockPhase: .infant,
                phaseExclusive: false,
                activityCost: 5,
                effects: ["clean": 12, "happiness": 6, "stamina": -2],
                expGain: 3,
                successMessage: "털을 빗어주니까 깔끔해져요!",
                failMessage: "너무 지쳐서 가만히 있을 수 없어요...",
                timeRestriction: nil
            ),
            
            // 특별 액션들 중 특수 이벤트와 겹치지 않는 것만 유지
            PetAction(
                id: "special_training",
                icon: "dumbbellIcom",
                name: "특별훈련",
                unlockPhase: .adolescent,
                phaseExclusive: false,
                activityCost: 15,
                effects: ["healthy": 15, "stamina": -12, "satiety": -10, "happiness": 8],
                expGain: 12,
                successMessage: "특별 훈련으로 더욱 강해졌어요!",
                failMessage: "특별 훈련을 받기엔 너무 지쳐있어요...",
                timeRestriction: TimeRestriction(startHour: 9, endHour: 17, isInverted: false) // 훈련소 운영시간
            ),
            
            PetAction(
                id: "stretch_exercise",
                icon: "yogaIcon",
                name: "스트레칭",
                unlockPhase: .child,
                phaseExclusive: false,
                activityCost: 7,
                effects: ["healthy": 10, "stamina": 8, "satiety": -3],
                expGain: 6,
                successMessage: "스트레칭으로 몸이 가벼워졌어요!",
                failMessage: "지금은 운동할 기분이 아니에요...",
                timeRestriction: TimeRestriction(startHour: 7, endHour: 21, isInverted: false)
            ),
            PetAction(
                id: "teach_trick",
                icon: "toyIcon",
                name: "재주 가르치기",
                unlockPhase: .adolescent,
                phaseExclusive: false,
                activityCost: 8,
                effects: ["happiness": 10, "stamina": -7, "satiety": -5],
                expGain: 8,
                successMessage: "새로운 재주를 배웠어요!",
                failMessage: "지금은 집중할 수 없어요...",
                timeRestriction: nil
            ),
            PetAction(
                id: "pet_head",
                icon: "loveHeartIcon2",
                name: "머리 쓰다듬기",
                unlockPhase: .infant,
                phaseExclusive: false,
                activityCost: 2,
                effects: ["happiness": 10, "stamina": 3],
                expGain: 3,
                successMessage: "머리를 쓰다듬어주니 행복해요!",
                failMessage: "지금은 쓰다듬기 싫어요...",
                timeRestriction: nil
            ),
            
            PetAction(
                id: "scratch_belly",
                icon: "bearLoveIcon",
                name: "배 긁어주기",
                unlockPhase: .child,
                phaseExclusive: false,
                activityCost: 3,
                effects: ["happiness": 15, "stamina": 2],
                expGain: 4,
                successMessage: "배를 긁어주니 너무 좋아요!",
                failMessage: "지금은 배를 만지기 싫어요...",
                timeRestriction: nil
            ),
            
            PetAction(
                id: "shade_rest",
                icon: "treeIcon",
                name: "그늘 아래 쉬기",
                unlockPhase: .infant,
                phaseExclusive: false,
                activityCost: 4,
                effects: ["stamina": 7, "happiness": 10, "clean": 3],
                expGain: 2,
                successMessage: "시원한 그늘 아래서 쉬니까 정말 편안해요!",
                failMessage: "지금은 쉬고 싶은 기분이 아니에요...",
                timeRestriction: TimeRestriction(startHour: 10, endHour: 18, isInverted: false)
            ),
            PetAction(
                id: "snack_give",
                icon: "pancake",
                name: "간식주기",
                unlockPhase: .infant,
                phaseExclusive: false,
                activityCost: 2,
                effects: ["satiety": 6, "happiness": 4],
                expGain: 2,
                successMessage: "간식을 맛있게 먹었어요!",
                failMessage: "지금은 간식이 먹고 싶지 않아요...",
                timeRestriction: nil
            ),
        ]
    }
}
