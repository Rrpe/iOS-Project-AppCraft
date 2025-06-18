//
//  GRUser.swift
//  Grruung
//
//  Created by NoelMacMini on 4/30/25.
//
import SwiftUI
import FirebaseFirestore

struct GRUser: Identifiable {
    // 기본 식별자
    var id: String
    
    // 사용자 정보
    var userEmail: String
    var userName: String
    var registeredAt: Date
    var lastUpdatedAt: Date
    var gold: Int
    var diamond: Int
    var chosenCharacterUUID: String
    
    // 기본값을 가진 생성자
    init(id: String = UUID().uuidString,
         userEmail: String = "",
         userName: String = "",
         registeredAt: Date = Date(),
         lastUpdatedAt: Date = Date(),
         gold: Int = 0,
         diamond: Int = 0,
         chosenCharacterUUID: String = ""
    ) {
        self.id = id
        self.userEmail = userEmail
        self.userName = userName
        self.registeredAt = registeredAt
        self.lastUpdatedAt = lastUpdatedAt
        self.gold = gold
        self.diamond = diamond
        self.chosenCharacterUUID = chosenCharacterUUID
    }
    
    // Firestore에 저장할 Dictionary 변환
    func toFirestoreData() -> [String: Any] {
        let data: [String: Any] = [
            "userEmail": userEmail,
            "userName": userName,
            "registeredAt": Timestamp(date: registeredAt),
            "lastUpdatedAt": Timestamp(date: lastUpdatedAt),
            "gold": gold,
            "diamond": diamond,
            "chosenCharacterUUID": chosenCharacterUUID
        ]
        return data
    }
    
    // Firestore에서 불러오기
    static func fromFirestore(document: DocumentSnapshot) -> GRUser? {
        guard let data = document.data() else { return nil }
        
        return GRUser(
            id: document.documentID,
            userEmail: data["userEmail"] as? String ?? "",
            userName: data["userName"] as? String ?? "",
            registeredAt: (data["registeredAt"] as? Timestamp)?.dateValue() ?? Date(),
            lastUpdatedAt: (data["lastUpdatedAt"] as? Timestamp)?.dateValue() ?? Date(),
            gold: data["gold"] as? Int ?? 0,
            diamond: data["diamond"] as? Int ?? 0,
            chosenCharacterUUID: data["chosenCharacterUUID"] as? String ?? ""
        )
    }
    
}
