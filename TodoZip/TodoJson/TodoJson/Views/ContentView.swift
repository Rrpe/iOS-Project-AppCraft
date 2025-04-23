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
            }
        }
        
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoStore(userId: "user1"))
}
