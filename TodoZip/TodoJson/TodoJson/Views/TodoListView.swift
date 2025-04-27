//
//  TodoListView.swift
//  TodoJson
//
//  Created by KimJunsoo on 4/25/25.
//

import SwiftUI

struct TodoListView: View {
    
    @EnvironmentObject private var todoStore: TodoStore
    let todos: [TodoItem]
    let emptyMessage: String
    var onDelete: ((IndexSet) -> Void)?
    
    var body: some View {
        if todos.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
                
                Text(emptyMessage)
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(todos) { todo in
                    NavigationLink(destination: TodoDetailView(todo: todo)) {
                        TodoItemRow(todo: todo)
                    }
                }
                .onDelete(perform: onDelete)
            }
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - 섹션별 할 일 그룹화를 위한 확장
extension TodoItem {
    /// 마감일 기준으로 섹션 분류
    var dueDateSection: String {
        guard let dueDate = self.dueDate else {
            return "마감일 없음"
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let dueDay = Calendar.current.startOfDay(for: dueDate)
        let components = Calendar.current.dateComponents([.day], from: today, to: dueDay)
        
        if let days = components.day {
            if days < 0 {
                return "지난 할 일"
            } else if days == 0 {
                return "오늘"
            } else if days == 1 {
                return "내일"
            } else if days < 7 {
                return "이번 주"
            } else {
                return "나중에"
            }
        }
        
        return "기타"
    }
    
    /// 완료 상태 기준으로 섹션 분류
    var completionSection: String {
        return isCompleted ? "완료됨" : "진행 중"
    }
}

// MARK: - 사용자별 할 일 필터링 확장
extension Collection where Element == TodoItem {
    /// 사용자 ID로 할 일 필터링
    func filterByUser(userId: String) -> [TodoItem] {
        return self.filter { $0.userId == userId }
    }
    
    /// 완료 여부로 할 일 필터링
    func filterByCompletion(isCompleted: Bool) -> [TodoItem] {
        return self.filter { $0.isCompleted == isCompleted }
    }
    
    /// 마감일 기준으로 할 일 필터링
    func filterByDueDate(hasDueDate: Bool) -> [TodoItem] {
        return self.filter { (hasDueDate && $0.dueDate != nil) || (!hasDueDate && $0.dueDate == nil) }
    }
    
    /// 마감일 지난 할 일 필터링
    func filterOverdue() -> [TodoItem] {
        let now = Date()
        return self.filter {
            guard let dueDate = $0.dueDate else { return false }
            return dueDate < now && !$0.isCompleted
        }
    }
}


#Preview {
    NavigationStack {
        TodoListView(
            todos: TodoItem.sample,
            emptyMessage: "할 일이 없습니다"
        ) { _ in
            // 프리뷰에서는 삭제 동작 없음
        }
    }
    .environmentObject(TodoStore(userId: "user1"))
}
