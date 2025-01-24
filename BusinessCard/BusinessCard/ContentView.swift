//
//  ContentView.swift
//  BusinessCard
//
//  Created by KimJunsoo on 1/21/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
//    @Environment(\.modelContext) private var modelContext
    @Query private var cards: [CardData]
    
    var body: some View {
        TabView {
            BusinessCardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("내 명함")
                }
            ListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("명함 리스트")
                }
            NavigationStack { // addCardView()
                Text("Scecond View & Tab")
                    .navigationTitle("명함 만들기")
            }
            .tabItem {
                Image(systemName: "plus.rectangle")
                Text("명함 추가")
            }
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: CardData.self, inMemory: true)
}
