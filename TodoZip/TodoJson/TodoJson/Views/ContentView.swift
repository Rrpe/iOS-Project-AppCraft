//
//  ContentView.swift
//  TodoJson
//
//  Created by KimJunsoo on 4/23/25.
//

import SwiftUI

// MARK: - 6. ContentView 정의 (메인 화면)
struct ContentView: View {
    
    @EnvironmentObject private var todoStore: TodoStore
    @State private var isAddTodoSheetPresented = false
    @State private var sortOption: SortOption = .createdAt
    @State private var showCompleted = true
    
    enum SortOption {
        case createdAt, dueDate, title
        
        var title: String {
            switch self {
            case .createdAt: return "생성일"
            case .dueDate: return "마감일"
            case .title: return "제목"
            }
        }
    }
    
    private var filteredAndSortedTodos: [TodoItem] {
        let filtered = showCompleted ? todoStore.todos : todoStore.todos.filter { !$0.isCompleted }
        
        switch sortOption {
        case .createdAt:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .dueDate:
            return filtered.sorted {
                if let dueDate1 = $0.dueDate, let dueDate2 = $1.dueDate {
                    return dueDate1 < dueDate2
                }
                return $0.dueDate != nil && $1.dueDate == nil
            }
        case .title:
            return filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }
    
    var body: some View {
        
        NavigationStack {
            VStack {
                HStack {
                    Toggle("완료 항목 표시", isOn: $showCompleted)
                        .toggleStyle(.switch)
                        .padding(.trailing)
                    
                    Spacer()
                    
                    Menu {
                        Picker("정렬 기준", selection: $sortOption) {
                            Text(SortOption.createdAt.title).tag(SortOption.createdAt)
                            Text(SortOption.dueDate.title).tag(SortOption.dueDate)
                            Text(SortOption.title.title).tag(SortOption.title)
                        }
                    } label: {
                        Label("정렬: \(sortOption.title)", systemImage: "arrow.up.arrow.down")
                    }
                }
                .padding(.horizontal)
                
                if filteredAndSortedTodos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        
                        Text("할 일이 없습니다.")
                            .font(.title2)
                            .foregroundStyle(.gray)
                        
                        Button("할 일 추가하기") {
                            isAddTodoSheetPresented = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredAndSortedTodos) { todo in
                            NavigationLink(destination: TodoDetailView(todo: todo)) {
                                TodoItemRow(todo: todo)
                            }
                        }
                        .onDelete(perform: deleteTodos)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("할 일 목록")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddTodoSheetPresented = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(role: .destructive, action: {
                            todoStore.clearCompletedTodos()
                        }) {
                            Label("완료된 항목 삭제", systemImage: "trash")
                        }
                        
                        Button(role: .destructive, action: {
                            todoStore.clearAllTodos()
                        }) {
                            Label("모든 항목 삭제", systemImage: "trash.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $isAddTodoSheetPresented) {
                AddTodoView()
            }
        }
    } // View
    
    private func deleteTodos(at indexSet: IndexSet) {
        for index in indexSet {
            let todoToDelete = filteredAndSortedTodos[index]
            todoStore.deleteTodo(withId: todoToDelete.id)
        }
    }
}

// MARK: - 7. TodoItemRow 정의
struct TodoItemRow: View {
    var todo: TodoItem
    
    @EnvironmentObject private var todoStore: TodoStore
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack {
            Button(action: {
                todoStore.toggleCompletion(forId: todo.id)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.headline)
                    .foregroundStyle(todo.isCompleted ? .gray : .primary)
                    .strikethrough(todo.isCompleted)
                
                HStack(spacing: 12) {
                    if let description = todo.description, !description.isEmpty {
                        Label("메모", systemImage: "note.text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let dueDate = todo.dueDate {
                        Label(dateFormatter.string(from: dueDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(isDueDatePassed(dueDate) && !todo.isCompleted ? .red : .secondary)
                    }
                }
            }
            
        }
        .padding()
    }
    
    private func isDueDatePassed(_ dueDate: Date) -> Bool {
        return dueDate < Date()
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoStore(userId: "user1"))
}
