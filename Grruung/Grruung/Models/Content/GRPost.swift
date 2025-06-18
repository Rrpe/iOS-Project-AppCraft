//
//  GRPost.swift
//  Grruung
//
//  Created by KimJunsoo on 5/7/25.
//

import Foundation
import FirebaseFirestore

// 캐릭터에게 들려준 이야기를 담는 구조체
struct GRPost {
    
    var postID: String = UUID().uuidString
    var characterUUID: String
    var postTitle: String
    var postBody: String
    var postImage: String // 이미지 URL 또는 경로 배열
    var createdAt: Date
    var updatedAt: Date
    
    init(postID: String = UUID().uuidString,
         characterUUID: String,
         postTitle: String,
         postBody: String,
         postImage: String,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.postID = postID
        self.characterUUID = characterUUID
        self.postTitle = postTitle
        self.postBody = postBody
        self.postImage = postImage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Firestore에서 불러오기
    static func GRPostFromFirestore(document: DocumentSnapshot) -> GRPost? {
        guard let data = document.data() else { return nil }
        
        return GRPost(
            postID: document.documentID,
            characterUUID: data["characterUUID"] as? String ?? "",
            postTitle: data["postTitle"] as? String ?? "",
            postBody: data["postBody"] as? String ?? "",
            postImage: data["postImage"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
