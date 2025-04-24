//
//  TodoDetailView.swift
//  TodoJson
//
//  Created by KimJunsoo on 4/24/25.
//

import SwiftUI

// MARK: - 8. TOdoDetailView 정의
struct TodoDetailView: View {
    let todo: TodoItem
    
    @EnvironmentObject private var todoStore: TodoStore
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var editedDueDate: Date?
    @State private var hasDueDate = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        List {
            // 제목
            Section {
                if isEditing {
                    TextField("제목", text: $editedTitle)
                        .font(.headline)
                } else {
                    Text(todo.title)
                        .font(.headline)
                        .foregroundStyle(todo.isCompleted ? .gray : .primary)
                }
            } header: {
                Text("제목")
            }
            
            // 설명
            Section {
                if isEditing {
                    TextEditor(text: $editedDescription)
                        .frame(minHeight: 100)
                } else {
                    Text(todo.description ?? "설명 없음")
                        .foregroundStyle(todo.description == nil ? .gray : .primary)
                }
            } header: {
                Text("설명")
            }
            
            // 날짜
            Section {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(.blue)
                    Text("생성일")
                    Spacer()
                    Text(dateFormatter.string(from: todo.createdAt))
                        .foregroundColor(.secondary)
                }
                
                if isEditing {
                    Toggle("마감일 설정", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("마감일", selection: Binding(
                            get: { editedDueDate ?? Date() },
                            set: { editedDueDate = $0 }
                        ), displayedComponents: [.date, .hourAndMinute])
                    }
                } else if let dueDate = todo.dueDate {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(.orange)
                        Text("마감일")
                        Spacer()
                        Text(dateFormatter.string(from: dueDate))
                            .foregroundStyle(isDueDatePassed(dueDate) && !todo.isCompleted ? .red : .secondary)
                    }
                }
            } header: {
                Text("날짜")
            }
            
            // 상태
            Section {
                HStack {
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(todo.isCompleted ? .green : .gray)
                    Text("상태")
                    Spacer()
                    Text(todo.isCompleted ? "완료됨" : "진행 중")
                        .foregroundStyle(todo.isCompleted ? .green : .orange)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    todoStore.toggleCompletion(forId: todo.id)
                }
            } header: {
                Text("상태")
            }
            
            // 작업
            if !isEditing {
                Section {
                    Button(role: .destructive, action: {
                        todoStore.deleteTodo(withId: todo.id)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("할 일 삭제")
                        }
                    }
                } header: {
                    Text("작업")
                }
            }
        }
        .navigationTitle("할 일 상세")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("저장") {
                        saveTodoChanges()
                        isEditing = false
                    }
                } else {
                    Button("편집") {
                        prepareForEditing()
                        isEditing = true
                    }
                }
            }
            
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        isEditing = false
                    }
                }
            }
        }
        .onAppear {
            prepareForEditing()
        }
    } // View
    
    private func isDueDatePassed(_ date: Date) -> Bool {
        return date < Date()
    }
    
    private func prepareForEditing() {
        editedTitle = todo.title
        editedDescription = todo.description ?? ""
        editedDueDate = todo.dueDate
        hasDueDate = todo.dueDate != nil
    }
    
    private func saveTodoChanges() {
        var updatedTodo = todo
        updatedTodo.title = editedTitle
        updatedTodo.description = editedDescription.isEmpty ? nil : editedDescription
        updatedTodo.dueDate = hasDueDate ? editedDueDate : nil
        
        todoStore.updateTodo(updatedTodo)
    }
    
}
