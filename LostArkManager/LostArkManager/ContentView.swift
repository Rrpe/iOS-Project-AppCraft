//
//  ContentView.swift
//  LostArkManager
//
//  Created by KimJunsoo on 2/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        
#if os(macOS)
        NavigationSplitView {
            
        }
#endif
        
        
#if os(iOS)
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
            
            Text("기타 메뉴")
                .tabItem {
                    Image(systemName: "ellipsis") 
                }
        }
        
#endif
    }
} // ContentView

#Preview {
    ContentView()
    //        .modelContainer(for: _.self, inMemory: true)
}
