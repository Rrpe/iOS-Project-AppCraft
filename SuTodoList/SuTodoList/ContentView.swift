//
//  ContentView.swift
//  SuTodoList
//
//  Created by KimJunsoo on 1/17/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State var title: String = ""
    @State var timestamp: Date = Date()
    @State var isFinish: Bool = false
    
    @State var searchToggle: Bool = false
    @State var searchText: String = ""
    @State var showErrorMessage: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    
    let defaultItems = [
        Item(title: "운동하기", timestamp: Date(), isFinish: false),
        Item(title: "책 읽기", timestamp: Date(), isFinish: false)
    ]

    var body: some View {
            NavigationStack {
                VStack {
                    // 검색 부분
                    HStack {
                        if searchToggle {
                            TextField("제목을 입력하세요", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            if !filteredItems.isEmpty {
                                NavigationLink(destination: SearchResultView(searchText: searchText)) {
                                    Text("Search")
                                        .padding()
                                        .foregroundStyle(.white)
                                        .background(.gray)
                                        .cornerRadius(0)
                                }
                            } else {
                                Button(action: {
                                    performSearch()
                                }) {
                                    Text("Search")
                                        .padding()
                                        .foregroundStyle(.white)
                                        .background(.gray)
                                        .cornerRadius(0)
                                }
                            }
                        }
                        
                    }
                    .padding()
                    if showErrorMessage {
                        Text("검색 결과가 없습니다.")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal)
                            .onAppear() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    withAnimation {
                                        showErrorMessage = false
                                    }
                                }
                            }
                    }
                    
                    // 할 일 목록 리스트
                    List {
                        ForEach(items) { item in
                            NavigationLink(destination: EditPageView(item: item)) {
                                HStack {
                                    Button(action: {
                                        toggleFinish(item: item)
                                    }) {
                                        Image(systemName: item.isFinish ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isFinish ? .green : .gray)
                                            .imageScale(.large)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Text(item.title ?? "Not found")
                                        .strikethrough(item.isFinish, color: .gray)
                                        .foregroundStyle(item.isFinish ? .gray : .black)
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("오늘의 할 일")
                            .font(.title2)
                            .bold()
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: AddPageView()) {
                                Label("추가", systemImage: "plus")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CalendarView()) {
                            Label("달력", systemImage: "calendar")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                searchToggle.toggle()
                                if !searchToggle {
                                    searchText = ""
                                }
                            }
                        }) {
                            Label("검색", systemImage: "magnifyingglass")
                        }
                    }
                } // .toolbar
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .onAppear {
                    initializeDefaultItem()
                }
                
            }
        }
    
    
    private func initializeDefaultItem() {
        if items.isEmpty {
            for defaultItem in defaultItems {
                modelContext.insert(defaultItem)
            }
        }
    }
        
    // 검색 수행 함수
    private func performSearch() {
        if filteredItems.isEmpty {
            showErrorMessage = true
        } else {
            showErrorMessage = false
        }
    }
    // 검색 결과 필터링
    private var filteredItems: [Item] {
        return items.filter { ($0.title ?? "").localizedCaseInsensitiveContains(searchText) }
    }

    private func toggleFinish(item: Item) {
        item.isFinish.toggle()
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
