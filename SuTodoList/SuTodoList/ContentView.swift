//
//  ContentView.swift
//  SuTodoList
//
//  Created by KimJunsoo on 1/17/25.
//

import SwiftUI
import SwiftData

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}


struct ContentView: View {
    
    @State var title: String = ""
    @State var timestamp: Date = Date()
    @State var isFinish: Bool = false
    
    @State var searchToggle: Bool = false
    @State var searchText: String = ""
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
            NavigationView {
                VStack {
                    HStack {
                        if searchToggle {
                            TextField("제목을 입력하세요", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            NavigationLink(destination: searchResultView(searchText: searchText)) {
                                Text("Search")
                            }
                            .padding()
                            .foregroundStyle(.white)
                            .background(.gray)
                        }
                    }
                    .padding()
                    
                    List {
                        ForEach(items) { item in
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
                        NavigationLink(destination: addPageView()) {
                                Label("Add", systemImage: "plus")
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
                            Label("search", systemImage: "magnifyingglass")
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        
    private var filteredItems: [Item] {
            if searchText.isEmpty {
                return items
            } else {
                return items.filter { ($0.title ?? "").localizedCaseInsensitiveContains(searchText) }
            }
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
