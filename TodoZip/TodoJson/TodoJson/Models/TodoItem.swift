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
         userid: String) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.userId = userid
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
