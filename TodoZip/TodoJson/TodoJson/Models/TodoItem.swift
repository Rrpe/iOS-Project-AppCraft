//
//  TodoItem.swift
//  TodoJson
//
//  Created by KimJunsoo on 4/23/25.
//

import Foundation

// MARK: 1. TodoItem 모델 정의
struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var description: String?
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var userId: String
    
    init(id: UUID = UUID(),
         title: String,
         description: String? = nil,
         isCompleted: Bool = false,
         createdAt: Date = Date(),
         dueDate: Date? = nil,
         userId: String) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.userId = userId
    }
    
    mutating func toggleCompleted() {
        isCompleted.toggle()
    }
    
    mutating func update(title: String, description: String?, dueDate: Date?) {
        self.title = title
        self.description = description
        self.dueDate = dueDate
    }
    
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: 2. 샘플 데이터
extension TodoItem {
    static var sample: [TodoItem] {
        return [
            TodoItem(title: "SwiftUI 학습하기", description: "SwiftUI의 기본 구조와 데이터 흐름 이해하기", isCompleted: false, userId: "user1"),
            TodoItem(title: "JSON 파일 저장 방식 구현", description: "FileManager를 활용한 로컬 데이터 저장 구현", isCompleted: false, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, userId: "user1"),
            TodoItem(title: "CRUD 기능 테스트", description: "생성, 읽기, 업데이트, 삭제 기능 테스트", isCompleted: true, userId: "user1")
        ]
    }
}
