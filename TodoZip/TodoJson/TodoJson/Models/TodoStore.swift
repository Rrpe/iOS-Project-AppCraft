//
//  TodoStore.swift
//  TodoJson
//
//  Created by KimJunsoo on 4/23/25.
//

import Foundation
import Combine

// MARK: - 4. TodoStore 클래스 정의 (데이터 관리 및 저장)
class TodoStore: ObservableObject {
    @Published var todos: [TodoItem] = []
    //    @Published var todos = [TodoItem]()
    
    private let userId: String
    
    private var fileURL: URL {
        return FileManager.getTodoFileURL(for: userId)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userId: String) {
        self.userId = userId
        
        if FileManager.fileExists(at: fileURL) {
            loadTodos()
        } else {
            todos = TodoItem.sample.filter { $0.userId == userId }
            saveTodos()
        }
        
        setupAutoSave()
    }
    
    private func setupAutoSave() {
        $todos
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveTodos()
            }
            .store(in: &cancellables)
    }
    
    func addTodo(_ todo: TodoItem) {
        todos.append(todo)
    }
    
    func getTodo(withId id: UUID) -> TodoItem? {
        return todos.first { $0.id == id }
    }
    
    func updateTodo(_ updateTodo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == updateTodo.id }) {
            todos[index] = updateTodo
        }
    }
    
    func deleteTodo(withId id: UUID) {
        todos.removeAll { $0.id == id }
    }
    
    func toggleCompletion(forId id: UUID) {
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index].toggleCompletion()
        }
    }
    
    func saveTodos() {
        do {
            try FileManager.saveJSON(todos, to: fileURL)
        } catch {
            print("🔴 Todo 저장 실패: \(error.localizedDescription)")
        }
    }
    
    func loadTodos() {
        do {
            todos = try FileManager.loadJSON(from: fileURL, as: [TodoItem].self)
        } catch {
            print("🔴 Todo 로드 실패: \(error.localizedDescription)")
            todos = []
        }
    }
    
    func clearAllTodos() {
        todos = []
    }
    
    func clearCompletedTodos() {
        todos.removeAll { $0.isCompleted }
    }
}
