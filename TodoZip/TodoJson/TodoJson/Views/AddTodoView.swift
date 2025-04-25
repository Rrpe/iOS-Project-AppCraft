//
//  AddTodoView.swift
//  TodoJson
//
//  Created by KimJunsoo on 4/25/25.
//

import SwiftUI

// MARK: - 9. AddTodoView 정의
struct AddTodoView: View {
    
    @EnvironmentObject private var todoStore: TodoStore
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                // 기본 정보
                Section {
                    TextField("할 일 제목", text: $title)
                    
                    TextField("설명 (선택사항)", text: $description, axis: .vertical)
                        .lineLimit(5, reservesSpace: true)
                } header: {
                    Text("기본 정보")
                }
                
                // 마감일
                Section {
                    Toggle("마감일 설정", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("마감일", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                } header: {
                    Text("마감일")
                }
            }
            .navigationTitle("할 일 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveNewTodo()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    } // View
    
    private func saveNewTodo() {
        let newTodo = TodoItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: false,
            createdAt: Date(),
            dueDate: hasDueDate ? dueDate : nil,
            userId: "user1"
        )
        
        todoStore.addTodo(newTodo)
        dismiss()
    }
}

// MARK: - 프리뷰
#Preview {
    AddTodoView()
        .environmentObject(TodoStore(userId: "user1"))
}
