//
//  ChatPetViewModel.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//

import Foundation
import Combine
import FirebaseFirestore

// 챗펫(AI 반려동물) 대화를 위한 ViewModel
class ChatPetViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // 오류 해결을 위해 추가된 프로퍼티
    @Published var showSubtitle: Bool = true // 자막 표시 여부
    @Published var isListening: Bool = false // 음성 인식 상태
    
    @Published var remainingChats: Int = 0
    @Published var showChatLimitAlert: Bool = false
    @Published var showBuyTicketAlert: Bool = false
    
    // 서비스
    private let vertexService = VertexAIService.shared
    private let firebaseService = FirebaseService.shared
    private let chatLimitManager = ChatLimitManager.shared

    // 대화 세션 관리
    private var currentSessionID: String?
    private var conversationContext: [ChatMessage] = []
    private var importantMemories: [[String: Any]] = []
    
    // 프롬프트 및 캐릭터 정보
    private var character: GRCharacter
    private var basePrompt: String
    
    private var cancellables = Set<AnyCancellable>()
    
    init(character: GRCharacter, prompt: String) {
        self.character = character
        self.basePrompt = prompt
        
        // 남은 채팅 횟수 초기화
        self.remainingChats = chatLimitManager.getRemainingChats()

        initializeChat()
    }
    
    // MARK: - 초기화 및 설정
    
    // 채팅 초기화
    private func initializeChat() {
        isLoading = true
        errorMessage = nil
        
        // 세션 가져오기 생성
        firebaseService.getOrCreateActiveSession(characterID: character.id) { [weak self] sessionID, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "세션 생성 실패: \(error.localizedDescription)"
                }
                return
            }
            
            if let sessionID = sessionID {
                self.currentSessionID = sessionID
                
                // 대화 기록 로드
                self.loadChatHistory()
                
                // 중요 기억 로드
                self.loadImportantMemories()
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "세션을 생성할 수 없습니다."
                }
            }
        }
    }
    
    // MARK: - 대화 기록 관리
    
    // Firestore에서 이전 대화 기록 로드
    func loadChatHistory() {
        guard let sessionID = currentSessionID else {
            isLoading = false
            return
        }
        
        firebaseService.fetchMessagesFromSession(
            sessionID: sessionID,
            characterID: character.id
        ) { [weak self] messages, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "대화 기록 로드 실패: \(error.localizedDescription)"
                    return
                }
                
                if let messages = messages {
                    self.messages = messages
                    self.updateConversationContext()
                    
                    // 메시지가 없을 경우 첫 인사 추가
                    if self.messages.isEmpty {
                        self.addGreetingMessage()
                    }
                }
            }
        }
    }
    
    // 중요 기억을 로드
    private func loadImportantMemories() {
        firebaseService.fetchImportantMemories(
            characterID: character.id,
            limit: 10
        ) { [weak self] memories, error in
            guard let self = self else { return }
            
            if let error = error {
                print("중요 기억 로드 실패: \(error.localizedDescription)")
                return
            }
            
            if let memories = memories {
                self.importantMemories = memories
            }
        }
    }
    
    // 대화 컨텍스트를 업데이트
    private func updateConversationContext() {
        // 최근 5-10개 메시지만 컨텍스트로 사용
        let contextCount = min(10, messages.count)
        if contextCount > 0 {
            conversationContext = Array(messages.suffix(contextCount))
        } else {
            conversationContext = []
        }
    }
    
    // 첫 인사 메시지 추가
    func addGreetingMessage() {
        // 성장 단계에 따른 인사말 생성
        // TODO: - 추후 변경 or 수정, 더 정교한 방식이 필요함
        let greeting: String
        
        switch character.status.phase {
        case .egg:
            greeting = "알 속에서 꿈틀거리고 있어요..."
        case .infant:
            if character.species == .CatLion {
                greeting = "냥...! 안녕하세요!"
            } else {
                greeting = "꾸잉...! 안녕하세요!"
            }
        case .child:
            if character.species == .CatLion {
                greeting = "어흥! 안녕하세요 주인님! 저는 \(character.name)이에요. 냥!"
            } else {
                greeting = "히히! 안녕하세요 주인님! 저는 \(character.name)이에요. 꾸잉!"
            }
        case .adolescent:
            if character.species == .CatLion {
                greeting = "그르릉~ 안녕하세요! 오늘은 무엇을 하고 싶으신가요?"
            } else {
                greeting = "꾸잉~ 안녕하세요! 오늘은 무엇을 하고 싶으신가요?"
            }
        case .adult, .elder:
            if character.species == .CatLion {
                greeting = "그르릉... 반갑습니다. 오랜만이네요. 무슨 이야기를 나눌까요?"
            } else {
                greeting = "꾸잉... 반갑습니다. 오랜만이네요. 무슨 이야기를 나눌까요?"
            }
        }
        
        let message = ChatMessage(text: greeting, isFromPet: true)
        addMessage(message)
    }
    
    // Firestore에 메시지 저장
    private func addMessage(_ message: ChatMessage) {
        messages.append(message)
        updateConversationContext()
        
        // 펫의 현재 상태 정보 생성
        let petStatus: [String: Any] = [
            "phase": character.status.phase.rawValue,
            "mood": getCurrentMood(),
            "dominant": getDominantStat()
        ]
        
        // Firestore에 저장
        firebaseService.saveChatMessageWithSession(
            message,
            characterID: character.id,
            sessionID: currentSessionID,
            petStatus: petStatus
        ) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "메시지 저장 실패: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // 현재 캐릭터의 기분 상태를 반환
    private func getCurrentMood() -> String {
        // 스텟에 따른 기분 상태 계산 (간단한 구현)
        // TODO: - 추후 변경 or 수정, 더 정교한 방식이 필요함
        let satiety = character.status.satiety
        let stamina = character.status.stamina
        let clean = character.status.clean
        let affection = character.status.affection
        
        if satiety < 30 {
            return "배고픔"
        } else if stamina < 30 {
            return "피곤함"
        } else if clean < 30 {
            return "불쾌함"
        } else if affection < 30 {
            return "외로움"
        } else if satiety > 70 && stamina > 70 && clean > 70 && affection > 70 {
            return "매우 행복함"
        } else if satiety > 50 && stamina > 50 && clean > 50 && affection > 50 {
            return "행복함"
        } else {
            return "보통"
        }
    }
    
    // 현재 가장 높은 스텟을 반환
    private func getDominantStat() -> String {
        let stats = [
            ("포만감", character.status.satiety),
            ("체력", character.status.stamina),
            ("청결", character.status.clean),
            ("애정", character.status.affection)
        ]
        
        return stats.max(by: { $0.1 < $1.1 })?.0 ?? "포만감"
    }
    
    // MARK: - 메시지 전송 및 응답 생성
    
    // 메시지 전송 및 챗펫 응답을 생성
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        // 채팅 횟수 확인 및 사용
        if !checkChatAvailability() {
            return
        }
        
        // 사용자 메시지 추가
        let userMessage = ChatMessage(text: inputText, isFromPet: false)
        addMessage(userMessage)
        
        let userInput = inputText
        inputText = ""
        
        // 챗펫 응답 생성
        generatePetResponse(to: userInput)
        
        // 남은 채팅 횟수 업데이트
        self.remainingChats = chatLimitManager.getRemainingChats()
    }
    
    // 채팅 가능 여부 확인
    private func checkChatAvailability() -> Bool {
        // 채팅 횟수가 남아있는 경우
        if chatLimitManager.useChat() {
            return true
        }
        
        // 채팅 횟수를 모두 사용한 경우 알림 표시
        showChatLimitAlert = true
        return false
    }
    
    // 남은 채팅 횟수 업데이트 메서드 추가
    func updateRemainingChats() {
        self.remainingChats = chatLimitManager.getRemainingChats()
    }
    
    // 챗펫 응답을 생성합니다.
    private func generatePetResponse(to userInput: String) {
        isLoading = true
        errorMessage = nil
        
        // 1. 맥락화된 프롬프트 생성
        let contextualPrompt = generateContextualPrompt(userInput: userInput)
        
        // 2. Vertex AI로 응답 생성
        vertexService.generatePetResponse(prompt: contextualPrompt) { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "응답 생성 실패: \(error.localizedDescription)"
                    return
                }
                
                if let response = response, !response.isEmpty {
                    // 응답에서 부적절한 내용 필터링
                    let filteredResponse = self.filterInappropriateContent(response)
                    
                    // 챗펫 응답 메시지 추가
                    let petMessage = ChatMessage(text: filteredResponse, isFromPet: true)
                    self.addMessage(petMessage)
                    
                    // 중요한 대화 내용 분석 및 저장
                    self.analyzeAndStoreImportantContent(userInput: userInput, response: filteredResponse)
                } else {
                    // 응답 생성 실패 시 기본 메시지
                    let defaultResponse: String
                    
                    if self.character.species == .CatLion {
                        defaultResponse = "냥...? (무슨 말인지 잘 이해하지 못한 것 같아요)"
                    } else {
                        defaultResponse = "꾸잉...? (무슨 말인지 잘 이해하지 못한 것 같아요)"
                    }
                    
                    let petMessage = ChatMessage(text: defaultResponse, isFromPet: true)
                    self.addMessage(petMessage)
                }
            }
        }
    }
    
    // 맥락화된 프롬프트를 생성
    private func generateContextualPrompt(userInput: String) -> String {
        var prompt = basePrompt
        
        // 1. 캐릭터 상태 정보 추가
        prompt += "\n\n현재 상태:"
        prompt += "\n- 포만감: \(character.status.satiety)/100"
        prompt += "\n- 체력: \(character.status.stamina)/100"
        prompt += "\n- 청결: \(character.status.clean)/100"
        prompt += "\n- 애정도: \(character.status.affection)/100"
        prompt += "\n- 기분: \(getCurrentMood())"
        
        // 2. 대화 컨텍스트 추가
        if !conversationContext.isEmpty {
            prompt += "\n\n최근 대화 내용:"
            
            for (_, message) in conversationContext.enumerated() {
                let speaker = message.isFromPet ? character.name : "사용자"
                prompt += "\n\(speaker): \(message.text)"
            }
        }
        
        // 3. 중요 기억 추가
        if !importantMemories.isEmpty {
            let relevantMemories = filterRelevantMemories(userInput: userInput, maxCount: 3)
            
            if !relevantMemories.isEmpty {
                prompt += "\n\n중요한 기억:"
                
                for memory in relevantMemories {
                    if let content = memory["content"] as? String {
                        prompt += "\n- \(content)"
                    }
                }
            }
        }
        
        // 4. 부적절한 콘텐츠 차단 지침 추가
        prompt += "\n\n중요 지침:"
        prompt += "\n- 사용자의 질문이 부적절하거나 불쾌감을 줄 수 있는 내용이라면, 정중하게 다른 주제로 대화를 전환하세요."
        prompt += "\n- 항상 캐릭터의 성격과 성장 단계에 맞는 어조와 표현을 사용하세요."
        
        // 5. 사용자 입력 추가
        prompt += "\n\n사용자: \(userInput)"
        prompt += "\n\(character.name): "
        
        return prompt
    }
    
    // 관련된 중요 기억을 필터링
    private func filterRelevantMemories(userInput: String, maxCount: Int) -> [[String: Any]] {
        // 키워드 매칭
        // TODO: - 추후 개선: 앱 출시시 더 정교한 방식 사용이 필요해보임
        let userWords = userInput.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        return importantMemories
            .filter { memory in
                if let content = memory["content"] as? String {
                    let memoryLower = content.lowercased()
                    return userWords.contains { word in
                        word.count > 3 && memoryLower.contains(word)
                    }
                }
                return false
            }
            .prefix(maxCount)
            .map { $0 }
    }
    
    // 부적절한 내용을 필터링
    private func filterInappropriateContent(_ text: String) -> String {
        // TODO: - 추후 개선: 앱 출시시 더 정교한 방식 사용이 필요해보임
        let inappropriateWords: [String] = ["비속어", "욕설", "성인", "19금"]
        
        var filteredText = text
        for word in inappropriateWords {
            filteredText = filteredText.replacingOccurrences(
                of: word,
                with: String(repeating: "*", count: word.count)
            )
        }
        
        return filteredText
    }
    
    // 중요한 대화 내용을 분석하고 저장
    private func analyzeAndStoreImportantContent(userInput: String, response: String) {
        // 중요 정보 키워드
        // TODO: - 추후 변경 or 수정, 더 정교한 방식이 필요함
        let importantKeywords = ["좋아하는", "싫어하는", "취미", "생일", "가족", "친구", "학교", "직장", "이름"]
        
        // 사용자 입력에서 중요 정보 검사
        for keyword in importantKeywords {
            if userInput.contains(keyword) || response.contains(keyword) {
                // 중요 정보가 포함된 대화 저장
                let memoryContent = "사용자: \(userInput)\n\(character.name): \(response)"
                let memoryData: [String: Any] = [
                    "content": memoryContent,
                    "importance": 7, // 중요도 높음
                    "emotionalContext": getCurrentMood(),
                    "category": "사용자_정보",
                    "timestamp": Timestamp(date: Date())
                ]
                
                firebaseService.storeImportantMemory(
                    memory: memoryData,
                    characterID: character.id
                ) { _ in }
                break // 하나의 중요 키워드만 처리
            }
        }
    }
    
    // MARK: - 세션 관리
    
    // 현재 대화 세션 종료
    func endCurrentsSession(completion: @escaping (Error?) -> Void) {
        guard let sessionID = currentSessionID else {
            completion(NSError(domain: "ChatPetViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "활성 세션이 없습니다."]))
            return
        }
        
        // 세션 요약 생성
        var summary = "대화 내용 요약: "
        if messages.count > 3 {
            let lastMessages = messages.suffix(3)
            summary += lastMessages.map { $0.text.prefix(30) + "..." }.joined(separator: ", ")
        } else {
            summary += "짧은 대화"
        }
        
        firebaseService.endConversationSession(
            sessionID: sessionID,
            characterID: character.id,
            summary: summary
        ) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
            } else {
                self.currentSessionID = nil
                
                // 새 세션 시작
                self.firebaseService.createConversationSession(
                    characterID: self.character.id
                ) { newSessionID, error in
                    if let newSessionID = newSessionID {
                        self.currentSessionID = newSessionID
                        completion(nil)
                    } else {
                        completion(error)
                    }
                }
            }
        }
    }
}
