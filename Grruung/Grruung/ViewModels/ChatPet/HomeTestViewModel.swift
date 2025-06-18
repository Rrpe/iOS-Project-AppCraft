//
//  HomeViewModel.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//

import Foundation
import Combine

// 홈 화면을 위한 ViewModel
class HomeTestViewModel: ObservableObject {
    // MARK: - 0. 바인딩 프로퍼티
    @Published var characters: [GRCharacter] = []
    @Published var selectedCharacter: GRCharacter?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - 상태 표시용 프로퍼티
    // 퍼센트로 표현된 값들 (UI의 ProgressView용)
    @Published var satietyPercent: CGFloat = 0.5
    @Published var staminaPercent: CGFloat = 0.5
    @Published var activityPercent: CGFloat = 0.5
    @Published var expPercent: CGFloat = 0.5
    
    // MARK: - 실제 스텟 값들 (0-100 Int)
    @Published var satietyValue: Int = 50
    @Published var staminaValue: Int = 50
    @Published var activityValue: Int = 50
    
    // 히든 스텟 값들
    @Published var healthyValue: Int = 50
    @Published var cleanValue: Int = 50
    @Published var affectionValue: Int = 50
    
    // 경험치 관련 값
    @Published var expValue: Int = 0
    @Published var expMaxValue: Int = 100
    
    // MARK: - 테스트 모드 프로퍼티
    @Published var testMode: Bool = false
    @Published var testSpecies: PetSpecies = .CatLion
    @Published var testPhase: CharacterPhase = .infant
    @Published var testName: String = ""
    
    // 서비스
    private let firebaseService = FirebaseService.shared
    private let userDefaults = UserDefaults.standard
    
    // 구독 취소용 객체
    private var cancellables = Set<AnyCancellable>()
    
    // 선택된 캐릭터 ID 유저 디폴트 키
    private let selectedCharacterKey = "SelectedCharacterID"
    
    // MARK: - 1. 이닛
    init() {
        setupBindings()
        loadSelectedCharacterID()
    }
    
    // MARK: - 2. 바인딩 설정
    private func setupBindings() {
        // 선택된 캐릭터 변경 시 상태 퍼센트 업데이트
        $selectedCharacter
            .compactMap { $0 }
            .sink { [weak self] character in
                guard let self = self else { return }
                self.updateStatusValues(character.status)
                self.saveSelectedCharacterID(character.id)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 3. 데이터 로드 메서드
    
    // 사용자의 모든 캐릭터 목록을 로드합니다.
    func loadCharacters() {
        isLoading = true
        errorMessage = nil
        
        firebaseService.fetchUserCharacters { [weak self] characters, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let characters = characters {
                    self.characters = characters
                    
                    // 저장된 선택 캐릭터 ID가 있으면 해당 캐릭터 선택
                    if let savedID = self.getSavedCharacterID(),
                       let savedCharacter = characters.first(where: { $0.id == savedID }) {
                        self.selectedCharacter = savedCharacter
                    }
                       
                    
                    // 선택된 캐릭터가 없으면 첫 번째 캐릭터 선택
                    if self.selectedCharacter == nil && !characters.isEmpty {
                        self.selectedCharacter = characters[0]
                    }
                }
            }
        }
    }
    
    // 테스트용 캐릭터를 생성하고 선택합니다.
    func createTestCharacter(
        name: String? = nil,
        satiety: Int = 70,
        stamina: Int = 60,
        activity: Int = 80,
        affection: Int = 90,
        healthy: Int = 85,
        clean: Int = 75
    ) {
        // 이름 설정 (입력된 이름이 없으면 기본 이름 사용)
        let characterName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? testSpecies.defaultName
        
        // 상태 생성
        let status = GRCharacterStatus(
            level: levelForPhase(testPhase),
            exp: expValue,
            expToNextLevel: expMaxValue,
            phase: testPhase,
            satiety: satiety,
            stamina: stamina,
            activity: activity,
            affection: affection,
            healthy: healthy,
            clean: clean
        )
        
        // 캐릭터 생성
        let character = GRCharacter(
            species: testSpecies,
            name: characterName,
            imageName: "\(testSpecies.rawValue)_\(testPhase.rawValue)",
            birthDate: Date(),
            createdAt: Date(),
            status: status
            
        )
        
        // 선택된 캐릭터로 설정
        selectedCharacter = character
        
        // 테스트 모드 설정
        testMode = true
    }
    
    // 테스트용 캐릭터를 Firestore에 저장합니다.
    func saveTestCharacterToFirestore() {
        guard let character = selectedCharacter, testMode else {
            errorMessage = "저장할 테스트 캐릭터가 없습니다."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        firebaseService.saveCharacter(character) { [weak self] error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "저장 실패: \(error.localizedDescription)"
            } else {
                // 테스트 모드 해제 (이제 실제 캐릭터)
                self.testMode = false
                
                // 캐릭터 목록 다시 로드
                self.loadCharacters()
            }
        }
    }
    
    // 캐릭터 성장 단계에 맞는 레벨을 반환합니다.
    private func levelForPhase(_ phase: CharacterPhase) -> Int {
        switch phase {
        case .egg:
            return 0
        case .infant:
            return 1
        case .child:
            return 3
        case .adolescent:
            return 6
        case .adult:
            return 9
        case .elder:
            return 16
        }
    }
    
    // MARK: - 4. 상태 업데이트 메서드
    
    // 캐릭터 상태를 업데이트합니다.
    func updateSelectedCharacter(
        satiety: Int? = nil,
        stamina: Int? = nil,
        activity: Int? = nil,
        affection: Int? = nil,
        healthy: Int? = nil,
        clean: Int? = nil
    ) {
        guard var character = selectedCharacter else { return }
        
        // 상태 업데이트
        character.updateStatus(
            satiety: satiety,
            stamina: stamina,
            activity: activity,
            affection: affection,
            healthy: healthy,
            clean: clean
        )
        
        // 선택된 캐릭터 갱신
        selectedCharacter = character
        
        // 테스트 모드가 아닌 경우에만 저장
        if !testMode {
            saveSelectedCharacter()
        }
    }
    
    // 선택된 캐릭터를 Firestore에 저장합니다.
    func saveSelectedCharacter() {
        guard let character = selectedCharacter else { return }
        
        isLoading = true
        errorMessage = nil
        
        firebaseService.saveCharacter(character) { [weak self] error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // 캐릭터에게 경험치를 추가합니다.
    func addExperience(_ amount: Int) {
        guard var character = selectedCharacter else { return }
        
        // 경험치 추가
        character.addExp(amount)
        
        // 선택된 캐릭터 갱신
        selectedCharacter = character
        
        // 테스트 모드가 아닌 경우에만 저장
        if !testMode {
            saveSelectedCharacter()
        }
    }
    
    // MARK: - 5. 상태 표시 메서드
    
    // 캐릭터 상태에 따라 상태 퍼센트와 실제 값을 업데이트합니다.
    private func updateStatusValues(_ status: GRCharacterStatus) {
        // 기본 스텟 값 업데이트
        satietyValue = status.satiety
        staminaValue = status.stamina
        activityValue = status.activity
        
        // 히든 스텟 값 업데이트
        healthyValue = status.healthy
        cleanValue = status.clean
        affectionValue = status.affection
        
        // 경험치 값 업데이트
        expValue = status.exp
        expMaxValue = status.expToNextLevel
        
        // UI용 퍼센트 값 업데이트
        satietyPercent = CGFloat(status.satiety) / 100.0
        staminaPercent = CGFloat(status.stamina) / 100.0
        activityPercent = CGFloat(status.activity) / 100.0
        
        // 경험치 퍼센트 계산
        if status.expToNextLevel > 0 {
            expPercent = CGFloat(status.exp) / CGFloat(status.expToNextLevel)
        } else {
            expPercent = 1.0
        }
    }
    
    // 선택된 캐릭터의 상태 메시지를 반환합니다.
    func getStatusMessage() -> String {
        guard let character = selectedCharacter else {
            return "캐릭터를 선택해주세요."
        }
        
        return character.getStatusMessage()
    }
    
    // MARK: - 6. 채팅 관련 메서드
    
    // 채팅 화면으로 이동하기 위한 챗펫 프롬프트를 생성합니다.
    func generateChatPetPrompt() -> String? {
        guard let character = selectedCharacter else { return nil }
        
        let petPrompt = PetPrompt(
            petType: character.species,
            phase: character.status.phase,
            name: character.name
        )
        
        return petPrompt.generatePrompt(status: character.status)
    }
    
    // MARK: - 캐릭터 선택 상태 저장/로드
    
    // 선택한 캐릭터 ID를 UserDefaults에 저장합니다.
    private func saveSelectedCharacterID(_ characterID: String) {
        userDefaults.set(characterID, forKey: selectedCharacterKey)
    }
    
    //
    private func getSavedCharacterID() -> String? {
        return userDefaults.string(forKey: selectedCharacterKey)
    }
    
    //
    private func loadSelectedCharacterID() {
        if let savedID = getSavedCharacterID(),
           !savedID.isEmpty {
            // 캐릭터 목록을 로드한 후 ID에 맞는 캐릭터를 찾아 선택 (loadCharacters에서 처리)
            print("저장된 캐릭터 ID: \(savedID)")
        }
    }
}
