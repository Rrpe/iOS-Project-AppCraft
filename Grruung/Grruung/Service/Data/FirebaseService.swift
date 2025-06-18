//
//  FirebaseService.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

// Firebase 관련 작업을 처리하는 서비스 클래스
class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private init() {}
    
    // 현재 로그인된 사용자의 UID를 반환
    func getCurrentUserID() -> String? {
        return auth.currentUser?.uid
    }
    
    // MARK: - 캐릭터 관련 메서드
    // Firestore에서 사용자의 모든 캐릭터 목록을 가져옴
    func fetchUserCharacters(completion: @escaping ([GRCharacter]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID).collection("characters")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                var characters: [GRCharacter] = []
                
                for document in documents {
                    let data = document.data()
                    
                    let id = document.documentID
                    let speciesRaw = data["species"] as? String ?? ""
                    let species = PetSpecies(rawValue: speciesRaw) ?? .CatLion
                    let name = data["name"] as? String ?? "이름 없음"
                    let imageName = data["image"] as? String ?? ""
                    
                    // 상태 정보 파싱
                    let statusData = data["status"] as? [String: Any] ?? [:]
                    let level = statusData["level"] as? Int ?? 1
                    let exp = statusData["exp"] as? Int ?? 0
                    let expToNextLevel = statusData["expToNextLevel"] as? Int ?? 100
                    let phaseRaw = statusData["phase"] as? String ?? ""
                    let phase = CharacterPhase(rawValue: phaseRaw) ?? .infant
                    let satiety = statusData["satiety"] as? Int ?? 50
                    let stamina = statusData["stamina"] as? Int ?? 50
                    let activity = statusData["activity"] as? Int ?? 50
                    let affection = statusData["affection"] as? Int ?? 50
                    let healthy = statusData["healthy"] as? Int ?? 50
                    let clean = statusData["clean"] as? Int ?? 50
                    let address = statusData["address"] as? String ?? "userHome"
                    let birthDateTimestamp = statusData["birthDate"] as? Timestamp
                    let birthDate = birthDateTimestamp?.dateValue() ?? Date()
                    let createdAtTimestamp = statusData["createdAt"] as? Timestamp
                    let createdAt = createdAtTimestamp?.dateValue() ?? Date()
                    let appearance = statusData["appearance"] as? [String: String] ?? [:]
                    let evolutionStatusRaw = statusData["evolutionStatus"] as? String ?? "eggComplete"
                    let evolutionStatus = EvolutionStatus(rawValue: evolutionStatusRaw) ?? .eggComplete
                    
                    let status = GRCharacterStatus(
                        level: level,
                        exp: exp,
                        expToNextLevel: expToNextLevel,
                        phase: phase,
                        satiety: satiety,
                        stamina: stamina,
                        activity: activity,
                        affection: affection,
                        healthy: healthy,
                        clean: clean,
                        address: address,
                        birthDate: birthDate,
                        appearance: appearance,
                        evolutionStatus: evolutionStatus
                    )
                    
                    let character = GRCharacter(
                        id: id,
                        species: species,
                        name: name,
                        imageName: imageName,
                        birthDate: birthDate,
                        createdAt: createdAt,
                        status: status
                    )
                    
                    characters.append(character)
                }
                
                completion(characters, nil)
            }
    }
    
    // 캐릭터 정보를 딕셔너리로 변환하는 부분에 createdAt 추가
    func saveCharacter(_ character: GRCharacter, completion: @escaping (Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 캐릭터 상태 정보를 딕셔너리로 변환
        let statusData: [String: Any] = [
            "level": character.status.level,
            "exp": character.status.exp,
            "expToNextLevel": character.status.expToNextLevel,
            "phase": character.status.phase.rawValue,
            "satiety": character.status.satiety,
            "stamina": character.status.stamina,
            "activity": character.status.activity,
            "affection": character.status.affection,
            "affectionCycle": character.status.affectionCycle, // 주간 애정도 추가
            "healthy": character.status.healthy,
            "clean": character.status.clean,
            "address": character.status.address,
            "birthDate": Timestamp(date: character.status.birthDate),
            "appearance": character.status.appearance,
            "evolutionStatus": character.status.evolutionStatus.rawValue
        ]
        
        // 캐릭터 정보를 딕셔너리로 변환
        let characterData: [String: Any] = [
            "species": character.species.rawValue,
            "name": character.name,
            "image": character.imageName,
            "status": statusData,
            "createdAt": Timestamp(date: character.createdAt), // createdAt 추가
            "updatedAt": Timestamp(date: Date()),
        ]
        
        // Firestore에 저장
        db.collection("users").document(userID).collection("characters").document(character.id)
            .setData(characterData, merge: true) { error in
                completion(error)
            }
    }
    
    // 캐릭터를 Firestore에서 삭제합니다.
    func deleteCharacter(id: String, completion: @escaping (Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 먼저 캐릭터가 메인인지 확인
        getMainCharacterID { [weak self] mainCharacterID, error in
            if let error = error {
                completion(error)
                return
            }
            
            // 캐릭터 삭제
            self?.db.collection("users").document(userID).collection("characters").document(id).delete { error in
                if let error = error {
                    completion(error)
                    return
                }
                
                // 삭제된 캐릭터가 메인이었다면 메인 캐릭터 초기화
                if mainCharacterID == id {
                    self?.db.collection("users").document(userID).updateData([
                        "chosenCharacterUUID": "",
                        "lastUpdatedAt": Timestamp(date: Date())
                    ]) { error in
                        completion(error)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - 채팅 메시지 관련 메서드
    // Firestore에 채팅 메시지를 저장
    func saveChatMessage(_ message: ChatMessage, characterID: String, completion: @escaping (Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        let messageData: [String: Any] = [
            "text": message.text,
            "isFromPet": message.isFromPet,
            "timestamp": Timestamp(date: message.timestamp)
        ]
        
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("messages").document(message.id)
            .setData(messageData) { error in
                completion(error)
            }
    }
    
    // Firestore에서 특정 캐릭터와의 채팅 메시지를 가져옴.
    func fetchChatMessages(characterID: String, limit: Int = 50, completion: @escaping ([ChatMessage]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                var messages: [ChatMessage] = []
                
                for document in documents {
                    let data = document.data()
                    
                    let text = data["text"] as? String ?? ""
                    let isFromPet = data["isFromPet"] as? Bool ?? false
                    let timestampData = data["timestamp"] as? Timestamp
                    let timestamp = timestampData?.dateValue() ?? Date()
                    
                    let message = ChatMessage(text: text, isFromPet: isFromPet, timestamp: timestamp)
                    messages.append(message)
                }
                
                // 시간순으로 정렬
                messages.sort { $0.timestamp < $1.timestamp }
                
                completion(messages, nil)
            }
    }
    
    // MARK: - 대화 세션 관리
    
    // 새로운 대화 세션을 생성
    func createConversationSession(
        characterID: String,
        sessionName: String? = nil,
        completion: @escaping (String?, Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 세션 이름 생성 (제공되지 않은 경우 시간 기반으로 생성)
        let name = sessionName ?? "\(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)) 대화"
        
        let sessionData: [String: Any] = [
            "startTime": Timestamp(date: Date()),
            "sessionName": name,
            "messageCount": 0,
            "active": true
        ]
        
        // Firestore에 세션 생성
        let sessionRef = db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("conversations").document("sessions")
            .collection("data").document()
        
        sessionRef.setData(sessionData) { error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(sessionRef.documentID, nil)
            }
        }
    }
    
    // 대화 세션을 종료
    func endConversationSession(
        sessionID: String,
        characterID: String,
        summary: String? = nil,
        completion: @escaping (Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 세션 업데이트 데이터
        var updateData: [String: Any] = [
            "endTime": Timestamp(date: Date()),
            "active": false
        ]
        
        // 요약이 제공된 경우 추가
        if let summary = summary {
            updateData["summary"] = summary
        }
        
        // Firestore 업데이트
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("conversations").document("sessions")
            .collection("data").document(sessionID)
            .updateData(updateData) { error in
                completion(error)
            }
    }
    
    // 활성 대화 세션 불러오기. 없으면 새로 생성
    func getOrCreateActiveSession(
        characterID: String,
        completion: @escaping (String?, Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 활성 세션 쿼리
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("conversations").document("sessions")
            .collection("data")
            .whereField("active", isEqualTo: true)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                // 활성 세션이 있는 경우
                if let document = snapshot?.documents.first {
                    completion(document.documentID, nil)
                    return
                }
                
                // 활성 세션이 없는 경우 새로 생성
                self.createConversationSession(characterID: characterID) { sessionID, error in
                    completion(sessionID, error)
                }
            }
    }
    
    // MARK: - 대화 메시지 관리
    
    // 메시지를 현재 활성 세션에 저장
    /// - Parameters:
    ///   - message: 대화 메시지
    ///   - characterID: 캐릭터 ID
    ///   - sessionID: 세션 ID (옵션, 제공되지 않으면 활성 세션 사용)
    ///   - petStatus: 펫 상태 요약 (옵션)
    ///   - completion: 완료 콜백
    func saveChatMessageWithSession(
        _ message: ChatMessage,
        characterID: String,
        sessionID: String? = nil,
        petStatus: [String: Any]? = nil,
        completion: @escaping (Error?) -> Void
    ) {
        // 세션 ID가 없으면 활성 세션 가져오기
        if let sessionID = sessionID {
            saveChatMessageToSession(message, characterID: characterID, sessionID: sessionID, petStatus: petStatus, completion: completion)
        } else {
            getOrCreateActiveSession(characterID: characterID) { [weak self] (sessionID, error) in
                guard let self = self else { return }
                
                if let error = error {
                    completion(error)
                    return
                }
                
                if let sessionID = sessionID {
                    self.saveChatMessageToSession(message, characterID: characterID, sessionID: sessionID, petStatus: petStatus, completion: completion)
                } else {
                    completion(NSError(domain: "FirebaseService", code: 500, userInfo: [NSLocalizedDescriptionKey: "세션을 생성할 수 없습니다."]))
                }
            }
        }
    }
    
    // 특정 세션에 메시지를 저장합니다.
    private func saveChatMessageToSession(
        _ message: ChatMessage,
        characterID: String,
        sessionID: String,
        petStatus: [String: Any]? = nil,
        completion: @escaping (Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 메시지 데이터 준비
        var messageData: [String: Any] = [
            "text": message.text,
            "isFromPet": message.isFromPet,
            "timestamp": Timestamp(date: message.timestamp),
            "sessionID": sessionID,
            "readByUser": !message.isFromPet
        ]
        
        // 펫 상태가 제공된 경우 추가
        if let petStatus = petStatus {
            messageData["petStatus"] = petStatus
        }
        
        // 트랜잭션으로 메시지 저장 및 세션 메시지 카운트 업데이트
        let batch = db.batch()
        
        // 1. 메시지 저장
        let messageRef = db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("conversations").document("messages")
            .collection("data").document(message.id)
        
        batch.setData(messageData, forDocument: messageRef)
        
        // 2. 세션 메시지 카운트 업데이트
        let sessionRef = db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("conversations").document("sessions")
            .collection("data").document(sessionID)
        
        batch.updateData(["messageCount": FieldValue.increment(Int64(1))], forDocument: sessionRef)
        
        // 3. 첫 메시지인 경우 fireMessageID 업데이트
        // 4. 마지막 메시지 ID 업데이트
        sessionRef.getDocument { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.exists else {
                completion(error ?? NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "세션을 찾을 수 없습니다."]))
                return
            }
            
            let data = snapshot.data() ?? [:]
            
            // 첫 메시지 ID 설정 (Empty일 경우)
            if data["firstMessageID"] == nil {
                batch.updateData(["firstMessageID": message.id], forDocument: sessionRef)
            }
            
            // 마지막 메시지 ID 업데이트
            batch.updateData(["lastMessageID": message.id], forDocument: sessionRef)
            
            // 트랜잭션 커밋
            batch.commit { error in
                completion(error)
                
                // 중요 메시지인 경우 기억으로 저장
                // 현재 20자 이상일 경우 중요 메시지로 기억되게 함
                if error == nil && message.isFromPet && message.text.count >= 20 {
                    self.storeMessageAsMemory(message: message, characterID: characterID)
                }
            }
        }
    }
    
    // 메시지를 기억으로 저장
    private func storeMessageAsMemory(
        message: ChatMessage,
        characterID: String,
        importance: Int = 5
    ) {
        guard let userID = getCurrentUserID() else { return }
        
        // 중요 대화 기억으로 저장
        let memoryData: [String: Any] = [
            "content": message.text,          // 기억의 내용 (메시지 텍스트)
            "timestamp": Timestamp(date: message.timestamp),  // 기억이 생성된 시간
            "importance": importance,         // 기억의 중요도 점수
            "emotionalContext": "대화",       // 기억과 연관된 감정적 맥락
            "category": "대화",               // 기억의 카테고리
            "mentionCount": 1,                // 이 기억이 언급된 횟수
            "messageID": message.id           // 원본 메시지 ID
        ]
        
        let memoryRef = db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("memories").document("important")
            .collection("data").document()
        
        memoryRef.setData(memoryData) { _ in
            // 저장 완료 (오류 무시)
        }
    }
    
    // MARK: - 대화 히스토리 조회
    
    // 특정 세션의 대화 메시지를 가져옴
    /// - Parameters:
    ///   - sessionID: 세션 ID
    ///   - characterID: 캐릭터 ID
    ///   - limit: 최대 메시지 수
    ///   - completion: 완료 콜백
    func fetchMessagesFromSession(
        sessionID: String,
        characterID: String,
        limit: Int = 50,
        completion: @escaping ([ChatMessage]?, Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("conversations").document("messages")
            .collection("data")
            .whereField("sessionID", isEqualTo: sessionID)
            .order(by: "timestamp", descending: false) // 시간순 정렬
            .limit(to: limit)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                let messages = documents.compactMap { document -> ChatMessage? in
                    let data = document.data()
                    
                    let text = data["text"] as? String ?? ""
                    let isFromPet = data["isFromPet"] as? Bool ?? false
                    let timestampData = data["timestamp"] as? Timestamp
                    let timestamp = timestampData?.dateValue() ?? Date()
                    
                    return ChatMessage(
                        text: text,
                        isFromPet: isFromPet,
                        timestamp: timestamp
                    )
                }
                
                completion(messages, nil)
            }
    }
    
    // 최근 N개의 대화 세션에서 메시지를 조회
    /// - Parameters:
    ///   - characterID: 캐릭터 ID
    ///   - sessionCount: 조회할 세션 수
    ///   - messagesPerSession: 세션당 메시지 수
    ///   - completion: 완료 콜백
    func fetchRecentConversations(
        characterID: String,
        sessionCount: Int = 3,
        messagesPerSession: Int = 20,
        completion: @escaping ([[ChatMessage]]?, Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 최근 세션 조회
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("conversations").document("sessions")
            .collection("data")
            .order(by: "startTime", descending: true)
            .limit(to: sessionCount)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    completion([], nil)
                    return
                }
                
                // 각 세션에서 메시지 조회
                var allSessionMessages: [[ChatMessage]] = []
                let group = DispatchGroup()
                
                for document in documents {
                    group.enter()
                    
                    let sessionID = document.documentID
                    self.fetchMessagesFromSession(
                        sessionID: sessionID,
                        characterID: characterID,
                        limit: messagesPerSession
                    ) { messages, error in
                        defer { group.leave() }
                        
                        if let messages = messages, !messages.isEmpty {
                            allSessionMessages.append(messages)
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    completion(allSessionMessages, nil)
                }
            }
    }
    
    // MARK: - 중요 기억 관리
    
    // 중요 기억을 조회합니다.
    /// - Parameters:
    ///   - characterID: 캐릭터 ID
    ///   - limit: 최대 기억 수
    ///   - completion: 완료 콜백
    func fetchImportantMemories(
        characterID: String,
        limit: Int = 20,
        completion: @escaping ([[String: Any]]?, Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("memories").document("important")
            .collection("data")
            .order(by: "importance", descending: true)
            .limit(to: limit)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                let memories = documents.map { $0.data() }
                completion(memories, nil)
            }
    }
    
    // 새로운 중요 기억을 저장합니다.
    /// - Parameters:
    ///   - memory: 기억 데이터
    ///   - characterID: 캐릭터 ID
    ///   - completion: 완료 콜백
    func storeImportantMemory(
        memory: [String: Any],
        characterID: String,
        completion: @escaping (Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 메모리에 타임스탬프 추가
        var memoryData = memory
        if memoryData["timestamp"] == nil {
            memoryData["timestamp"] = Timestamp(date: Date())
        }
        
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("memories").document("important")
            .collection("data").document()
    }
    
    // MARK: Start - HomeViewModel Character 연결을 위한 메서드 정의
    // MARK: - 메인 캐릭터 관리
    
    /// 사용자의 메인 캐릭터를 설정합니다.
    /// - Parameters:
    ///   - characterID: 메인으로 설정할 캐릭터 ID
    ///   - completion: 완료 콜백
    func setMainCharacter(characterID: String, completion: @escaping (Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 사용자 문서의 chosenCharacterUUID 필드 업데이트
        db.collection("users").document(userID).updateData([
            "chosenCharacterUUID": characterID,
            "lastUpdatedAt": Timestamp(date: Date())
        ]) { error in
            completion(error)
        }
    }
    
    /// 사용자의 메인 캐릭터 ID를 가져옵니다.
    /// - Parameter completion: 완료 콜백 (캐릭터 ID, 에러)
    func getMainCharacterID(completion: @escaping (String?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID).getDocument { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = snapshot?.data() else {
                completion(nil, NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "사용자 데이터를 찾을 수 없습니다."]))
                return
            }
            
            let characterID = data["chosenCharacterUUID"] as? String ?? ""
            completion(characterID.isEmpty ? nil : characterID, nil)
        }
    }
    
    /// 사용자의 메인 캐릭터를 로드합니다.
    /// - Parameter completion: 완료 콜백 (캐릭터, 에러)
    func loadMainCharacter(completion: @escaping (GRCharacter?, Error?) -> Void) {
        // 먼저 메인 캐릭터 ID를 가져온다
        getMainCharacterID { [weak self] characterID, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let characterID = characterID else {
                // 메인 캐릭터가 없으면 nil 반환
                completion(nil, nil)
                return
            }
            
            // 캐릭터 ID로 캐릭터 데이터 로드
            self.loadCharacterByID(characterID: characterID, completion: completion)
        }
    }
    
    /// 특정 ID의 캐릭터를 로드합니다.
    /// - Parameters:
    ///   - characterID: 로드할 캐릭터 ID
    ///   - completion: 완료 콜백 (캐릭터, 에러)
    func loadCharacterByID(characterID: String, completion: @escaping (GRCharacter?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .getDocument { (snapshot, error) in
                
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let document = snapshot, document.exists,
                      let data = document.data() else {
                    completion(nil, NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "캐릭터를 찾을 수 없습니다."]))
                    return
                }
                
                // 캐릭터 데이터 파싱
                let character = self.parseCharacterFromData(characterID: characterID, data: data)
                completion(character, nil)
            }
    }
    
    // MARK: - 실시간 캐릭터 동기화
    
    // 메인 캐릭터의 실시간 리스너를 설정합니다.
    /// - Parameter onChange: 캐릭터 변경 시 호출될 콜백
    /// - Returns: 리스너 해제용 Listener 객체
    func setupMainCharacterListener(onChange: @escaping (GRCharacter?, Error?) -> Void) -> ListenerRegistration? {
        guard let userID = getCurrentUserID() else {
            onChange(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return nil
        }
        
        // 사용자 문서의 chosenCharacterUUID 필드를 실시간으로 감시
        return db.collection("users").document(userID)
            .addSnapshotListener { [weak self] (userSnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    onChange(nil, error)
                    return
                }
                
                guard let userData = userSnapshot?.data(),
                      let characterID = userData["chosenCharacterUUID"] as? String,
                      !characterID.isEmpty else {
                    onChange(nil, nil)
                    return
                }
                
                // 캐릭터 문서에 실시간 리스너 설정
                self.db.collection("users").document(userID)
                    .collection("characters").document(characterID)
                    .addSnapshotListener { (characterSnapshot, error) in
                        
                        if let error = error {
                            onChange(nil, error)
                            return
                        }
                        
                        guard let document = characterSnapshot, document.exists,
                              let data = document.data() else {
                            onChange(nil, NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "캐릭터를 찾을 수 없습니다."]))
                            return
                        }
                        
                        // 캐릭터 데이터 파싱 후 콜백 호출
                        let character = self.parseCharacterFromData(characterID: characterID, data: data)
                        onChange(character, nil)
                    }
            }
    }
    
    // 캐릭터의 실시간 리스너를 설정합니다.
    /// - Parameters:
    ///   - characterID: 리스너를 설정할 캐릭터 ID
    ///   - onChange: 캐릭터 변경 시 호출될 콜백
    /// - Returns: 리스너 해제용 Listener 객체
    func setupCharacterListener(characterID: String, onChange: @escaping (GRCharacter?, Error?) -> Void) -> ListenerRegistration? {
        guard let userID = getCurrentUserID() else {
            onChange(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return nil
        }
        
        let listener = db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    onChange(nil, error)
                    return
                }
                
                guard let document = snapshot, document.exists,
                      let data = document.data() else {
                    onChange(nil, NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "캐릭터를 찾을 수 없습니다."]))
                    return
                }
                
                // 캐릭터 데이터 파싱 후 콜백 호출
                let character = self.parseCharacterFromData(characterID: characterID, data: data)
                onChange(character, nil)
            }
        
        return listener
    }
    
    // MARK: - 캐릭터 스탯 변화 추적
    
    /// 캐릭터 스탯 변화를 기록합니다.
    /// - Parameters:
    ///   - characterID: 캐릭터 ID
    ///   - changes: 변화된 스탯들 [스탯명: 변화량]
    ///   - reason: 변화 원인 (예: "feed_action", "timer_decrease", "level_up")
    ///   - completion: 완료 콜백
    func recordStatChanges(
        characterID: String,
        changes: [String: Int],
        reason: String,
        completion: @escaping (Error?) -> Void
    ) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        let changeRecord: [String: Any] = [
            "timestamp": Timestamp(date: Date()),
            "changes": changes,
            "reason": reason,
            "characterID": characterID
        ]
        
        // 스탯 변화 기록을 서브컬렉션에 저장
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .collection("statHistory").document()
            .setData(changeRecord) { error in
                completion(error)
            }
    }
    
    /// 캐릭터의 마지막 업데이트 시간을 기록합니다.
    /// - Parameters:
    ///   - characterID: 캐릭터 ID
    ///   - completion: 완료 콜백
    func updateCharacterLastActiveTime(characterID: String, completion: @escaping (Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .updateData([
                "lastActiveAt": Timestamp(date: Date())
            ]) { error in
                completion(error)
            }
    }
    
    /// 캐릭터의 마지막 활동 시간을 가져옵니다.
    /// - Parameters:
    ///   - characterID: 캐릭터 ID
    ///   - completion: 완료 콜백 (마지막 활동 시간, 에러)
    func getCharacterLastActiveTime(characterID: String, completion: @escaping (Date?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID)
            .collection("characters").document(characterID)
            .getDocument { (snapshot, error) in
                
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let data = snapshot?.data(),
                      let lastActiveTimestamp = data["lastActiveAt"] as? Timestamp else {
                    // 마지막 활동 시간이 없으면 현재 시간 반환
                    completion(Date(), nil)
                    return
                }
                
                completion(lastActiveTimestamp.dateValue(), nil)
            }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// Firestore 데이터에서 GRCharacter 객체를 생성합니다.
    /// - Parameters:
    ///   - characterID: 캐릭터 ID
    ///   - data: Firestore 문서 데이터
    /// - Returns: 파싱된 GRCharacter 객체
    private func parseCharacterFromData(characterID: String, data: [String: Any]) -> GRCharacter {
        // 기본 캐릭터 정보 파싱
        let speciesRaw = data["species"] as? String ?? ""
        let species = PetSpecies(rawValue: speciesRaw) ?? .CatLion
        let name = data["name"] as? String ?? "이름 없음"
        let imageName = data["image"] as? String ?? ""
        let createdAtTimestamp = data["createdAt"] as? Timestamp
        let createdAt = createdAtTimestamp?.dateValue() ?? Date()
        
        // 상태 정보 파싱
        let statusData = data["status"] as? [String: Any] ?? [:]
        let level = statusData["level"] as? Int ?? 1
        let exp = statusData["exp"] as? Int ?? 0
        let expToNextLevel = statusData["expToNextLevel"] as? Int ?? 100
        let phaseRaw = statusData["phase"] as? String ?? ""
        let phase = CharacterPhase(rawValue: phaseRaw) ?? .infant
        let satiety = statusData["satiety"] as? Int ?? 50
        let stamina = statusData["stamina"] as? Int ?? 50
        let activity = statusData["activity"] as? Int ?? 50
        let affection = statusData["affection"] as? Int ?? 50
        let affectionCycle = statusData["affectionCycle"] as? Int ?? 0
        let healthy = statusData["healthy"] as? Int ?? 50
        let clean = statusData["clean"] as? Int ?? 50
        let address = statusData["address"] as? String ?? "userHome"
        let birthDateTimestamp = statusData["birthDate"] as? Timestamp
        let birthDate = birthDateTimestamp?.dateValue() ?? Date()
        let appearance = statusData["appearance"] as? [String: String] ?? [:]
        let evolutionStatusRaw = statusData["evolutionStatus"] as? String ?? "eggComplete"
        let evolutionStatus = EvolutionStatus(rawValue: evolutionStatusRaw) ?? .eggComplete
        
        let status = GRCharacterStatus(
            level: level,
            exp: exp,
            expToNextLevel: expToNextLevel,
            phase: phase,
            satiety: satiety,
            stamina: stamina,
            activity: activity,
            affection: affection,
            affectionCycle: affectionCycle,
            healthy: healthy,
            clean: clean,
            address: address,
            birthDate: birthDate,
            appearance: appearance,
            evolutionStatus: evolutionStatus
        )
        
        return GRCharacter(
            id: characterID,
            species: species,
            name: name,
            imageName: imageName,
            birthDate: birthDate,
            createdAt: createdAt,
            status: status
        )
    }
    
    /// 캐릭터를 생성하고 메인 캐릭터로 설정합니다.
    /// - Parameters:
    ///   - character: 생성할 캐릭터
    ///   - setAsMain: 메인 캐릭터로 설정할지 여부
    ///   - completion: 완료 콜백 (생성된 캐릭터 ID, 에러)
    func createAndSetMainCharacter(
           character: GRCharacter,
           setAsMain: Bool = true,
           completion: @escaping (String?, Error?) -> Void
       ) {
           // 먼저 같은 address를 가진 캐릭터가 있는지 확인
           findCharactersByAddress(address: "userHome") { [weak self] existingCharacters, error in
               guard let self = self else { return }
               
               if let error = error {
                   completion(nil, error)
                   return
               }
               
               // 이미 userHome 주소를 가진 캐릭터가 있는 경우
               if let existingCharacters = existingCharacters, !existingCharacters.isEmpty {
                   // 이미 있는 캐릭터를 메인으로 설정
                   if setAsMain {
                       self.setMainCharacter(characterID: existingCharacters[0].id) { error in
                           if let error = error {
                               completion(nil, error)
                           } else {
                               completion(existingCharacters[0].id, nil)
                           }
                       }
                   } else {
                       completion(existingCharacters[0].id, nil)
                   }
                   return
               }
               
               // 없으면 새 캐릭터 저장
               self.saveCharacter(character) { [weak self] error in
                   guard let self = self else { return }
                   
                   if let error = error {
                       completion(nil, error)
                       return
                   }
                   
                   // 메인 캐릭터로 설정할지 확인
                   if setAsMain {
                       self.setMainCharacter(characterID: character.id) { error in
                           if let error = error {
                               completion(nil, error)
                           } else {
                               completion(character.id, nil)
                           }
                       }
                   } else {
                       completion(character.id, nil)
                   }
               }
           }
       }
    
    /// 모든 캐릭터 중 사용 가능한 수 (해금된 슬롯 수) 확인
    /// - Parameter completion: 완료 콜백 (사용 가능 슬롯 수, 전체 캐릭터 수, 에러)
    func getAvailableSlotCount(completion: @escaping (Int, Int, Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(0, 0, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 캐릭터 도감 정보 조회
        db.collection("charDex").document(userID).getDocument { (snapshot, error) in
            if let error = error {
                completion(0, 0, error)
                return
            }
            
            // 도감 정보에서 해금된 슬롯 수 확인
            let unlockCount = snapshot?.data()?["unlockCount"] as? Int ?? 2 // 기본값 2
            
            // 전체 캐릭터 수 확인 (space 주소 제외)
            self.db.collection("users").document(userID).collection("characters")
                .whereField("status.address", isNotEqualTo: "space")
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        completion(unlockCount, 0, error)
                        return
                    }
                    
                    let characterCount = snapshot?.documents.count ?? 0
                    completion(unlockCount, characterCount, nil)
                }
        }
    }
    
    /// 새 캐릭터 생성 가능 여부 확인
    /// - Parameter completion: 완료 콜백 (생성 가능 여부, 에러 메시지)
    func canCreateNewCharacter(completion: @escaping (Bool, String?) -> Void) {
        getAvailableSlotCount { unlockCount, characterCount, error in
            if let error = error {
                completion(false, "슬롯 정보를 확인하는 데 실패했습니다: \(error.localizedDescription)")
                return
            }
            
            if characterCount >= unlockCount {
                completion(false, "사용 가능한 슬롯이 부족합니다. 슬롯을 해금하거나 기존 캐릭터를 동산으로 보내주세요.")
            } else {
                completion(true, nil)
            }
        }
    }
    
    /// 캐릭터 성장 단계 설정
    /// - Parameters:
    ///   - characterID: 캐릭터 ID
    ///   - phase: 설정할 성장 단계
    ///   - completion: 완료 콜백
    func setCharacterPhase(characterID: String, phase: CharacterPhase, completion: @escaping (Error?) -> Void) {
        loadCharacterByID(characterID: characterID) { [weak self] character, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard var character = character else {
                completion(NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "캐릭터를 찾을 수 없습니다."]))
                return
            }
            
            // 성장 단계 업데이트
            character.status.phase = phase
            
            // 레벨도 함께 업데이트
            switch phase {
            case .egg:
                character.status.level = 0
            case .infant:
                character.status.level = max(1, character.status.level)
            case .child:
                character.status.level = max(3, character.status.level)
            case .adolescent:
                character.status.level = max(6, character.status.level)
            case .adult:
                character.status.level = max(9, character.status.level)
            case .elder:
                character.status.level = max(16, character.status.level)
            }
            
            // 저장
            self.saveCharacter(character, completion: completion)
        }
    }
    
    // End - HomeViewModel Character 연결을 위한 메서드 정의

    // MARK: - 캐릭터 중복 생성 방지를 위한 함수 추가

    // 특정 address에 있는 캐릭터 찾기
    func findCharactersByAddress(address: String, completion: @escaping ([GRCharacter]?, Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        db.collection("users").document(userID).collection("characters")
            .whereField("status.address", isEqualTo: address)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                var characters: [GRCharacter] = []
                
                for document in documents {
                    let data = document.data()
                    
                    let id = document.documentID
                    let speciesRaw = data["species"] as? String ?? ""
                    let species = PetSpecies(rawValue: speciesRaw) ?? .CatLion
                    let name = data["name"] as? String ?? "이름 없음"
                    let imageName = data["image"] as? String ?? ""
                    
                    // 상태 정보 파싱
                    let statusData = data["status"] as? [String: Any] ?? [:]
                    let level = statusData["level"] as? Int ?? 1
                    let exp = statusData["exp"] as? Int ?? 0
                    let expToNextLevel = statusData["expToNextLevel"] as? Int ?? 100
                    let phaseRaw = statusData["phase"] as? String ?? ""
                    let phase = CharacterPhase(rawValue: phaseRaw) ?? .infant
                    let satiety = statusData["satiety"] as? Int ?? 50
                    let stamina = statusData["stamina"] as? Int ?? 50
                    let activity = statusData["activity"] as? Int ?? 50
                    let affection = statusData["affection"] as? Int ?? 50
                    let healthy = statusData["healthy"] as? Int ?? 50
                    let clean = statusData["clean"] as? Int ?? 50
                    let address = statusData["address"] as? String ?? "userHome"
                    let birthDateTimestamp = statusData["birthDate"] as? Timestamp
                    let birthDate = birthDateTimestamp?.dateValue() ?? Date()
                    let createdAtTimestamp = data["createdAt"] as? Timestamp
                    let createdAt = createdAtTimestamp?.dateValue() ?? Date()
                    let appearance = statusData["appearance"] as? [String: String] ?? [:]
                    let evolutionStatusRaw = statusData["evolutionStatus"] as? String ?? "eggComplete"
                    let evolutionStatus = EvolutionStatus(rawValue: evolutionStatusRaw) ?? .eggComplete
                    
                    let status = GRCharacterStatus(
                        level: level,
                        exp: exp,
                        expToNextLevel: expToNextLevel,
                        phase: phase,
                        satiety: satiety,
                        stamina: stamina,
                        activity: activity,
                        affection: affection,
                        healthy: healthy,
                        clean: clean,
                        address: address,
                        birthDate: birthDate,
                        appearance: appearance,
                        evolutionStatus: evolutionStatus
                    )
                    
                    let character = GRCharacter(
                        id: id,
                        species: species,
                        name: name,
                        imageName: imageName,
                        birthDate: birthDate,
                        createdAt: createdAt,
                        status: status
                    )
                    
                    characters.append(character)
                }
                
                completion(characters, nil)
            }
    }
    
    func preFetchInitialData(userID: String) async {
        print("🔥 초기 데이터 프리페치 시작")
        
        // 병렬로 데이터 로드
        async let charDexTask = prefetchCharDex(userID: userID)
        async let inventoryTask = prefetchInventory(userID: userID)
        async let mainCharacterTask = prefetchMainCharacter(userID: userID)
        
        // 모든 작업 완료까지 대기
        _ = await [try? charDexTask, try? inventoryTask, try? mainCharacterTask]
        
        print("✅ 초기 데이터 프리페치 완료")
    }
    
    // 동산 데이터 프리페치
    private func prefetchCharDex(userID: String) async throws {
        let docRef = db.collection("charDex").document(userID)
        let _ = try await docRef.getDocument()
        print("✅ 동산 데이터 프리페치 완료")
    }
    
    // 인벤토리 데이터 프리페치
    private func prefetchInventory(userID: String) async throws {
        let collectionRef = db.collection("users").document(userID).collection("inventory")
        let _ = try await collectionRef.getDocuments()
        print("✅ 인벤토리 데이터 프리페치 완료")
    }
    
    // 메인 캐릭터 프리페치
    private func prefetchMainCharacter(userID: String) async throws {
        // 사용자 정보 로드
        let userRef = db.collection("users").document(userID)
        let userDoc = try await userRef.getDocument()
        
        // 메인 캐릭터 ID 가져오기
        guard let userData = userDoc.data(),
              let chosenCharacterUUID = userData["chosenCharacterUUID"] as? String,
              !chosenCharacterUUID.isEmpty else {
            print("❌ 메인 캐릭터 ID를 찾을 수 없습니다")
            return
        }
        
        // 메인 캐릭터 데이터 로드
        let characterRef = db.collection("users").document(userID).collection("characters").document(chosenCharacterUUID)
        let _ = try await characterRef.getDocument()
        
        print("✅ 메인 캐릭터 데이터 프리페치 완료")
    }
    
    func addExpAndGold(characterID: String, exp: Int, gold: Int) async throws {
        guard let userID = getCurrentUserID() else {
            throw NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."])
        }
        
        // 사용자 문서 참조
        let userRef = db.collection("users").document(userID)
        
        // 캐릭터 문서 참조
        let characterRef = userRef.collection("characters").document(characterID)
        
        // 1. 사용자 골드 업데이트
        let userDoc = try await userRef.getDocument()
        if let userData = userDoc.data() {
            let currentGold = userData["gold"] as? Int ?? 0
            try await userRef.updateData(["gold": currentGold + gold])
        }
        
        // 2. 캐릭터 경험치 업데이트 및 레벨업 처리
        let characterDoc = try await characterRef.getDocument()
        if let characterData = characterDoc.data(),
           var statusData = characterData["status"] as? [String: Any] {
            
            // 현재 값 가져오기
            var level = statusData["level"] as? Int ?? 1
            var currentExp = statusData["exp"] as? Int ?? 0
            var expToNextLevel = statusData["expToNextLevel"] as? Int ?? 100
            
            // 경험치 추가
            currentExp += exp
            
            // 레벨업 체크
            if currentExp >= expToNextLevel {
                level += 1
                currentExp -= expToNextLevel
                expToNextLevel = level * 100 // 간단한 레벨업 계산식
            }
            
            // 상태 객체 업데이트
            statusData["level"] = level
            statusData["exp"] = currentExp
            statusData["expToNextLevel"] = expToNextLevel
            
            // 전체 status 객체를 한 번에 업데이트
            try await characterRef.updateData(["status": statusData])
            
            print("💰 보상 획득: 경험치 \(exp), 골드 \(gold)")
        }
    }
    
    // MARK: - 메인 캐릭터 관리에 추가할 메서드

    /// 캐릭터를 메인으로 설정하고 나머지 캐릭터들을 동산으로 이동시킵니다.
    /// - Parameters:
    ///   - characterID: 메인으로 설정할 캐릭터 ID
    ///   - completion: 완료 콜백
    func setMainCharacterAndMoveOthersToParadise(characterID: String, completion: @escaping (Error?) -> Void) {
        guard let userID = getCurrentUserID() else {
            completion(NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증이 필요합니다."]))
            return
        }
        
        // 1. 먼저 모든 캐릭터를 가져와서 주소를 paradise로 변경
        fetchUserCharacters { [weak self] characters, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let characters = characters else {
                completion(NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "캐릭터 목록을 찾을 수 없습니다."]))
                return
            }
            
            // 2. 배치 작업으로 모든 캐릭터의 주소를 paradise로 변경
            let batch = self.db.batch()
            
            for character in characters {
                // space 주소는 제외 (이미 삭제된 캐릭터)
                if character.status.address != "space" {
                    let characterRef = self.db.collection("users").document(userID)
                        .collection("characters").document(character.id)
                    
                    // 선택된 캐릭터는 userHome, 나머지는 paradise로 설정
                    let newAddress = character.id == characterID ? "userHome" : "paradise"
                    
                    batch.updateData([
                        "status.address": newAddress,
                        "updatedAt": Timestamp(date: Date())
                    ], forDocument: characterRef)
                }
            }
            
            // 3. 사용자 문서의 chosenCharacterUUID 업데이트
            let userRef = self.db.collection("users").document(userID)
            batch.updateData([
                "chosenCharacterUUID": characterID,
                "lastUpdatedAt": Timestamp(date: Date())
            ], forDocument: userRef)
            
            // 4. 배치 커밋
            batch.commit { error in
                completion(error)
            }
        }
    }

}
