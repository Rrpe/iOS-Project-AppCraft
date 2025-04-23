//
//  TodoJsonApp.swift
//  TodoJson
//
//  Created by KimJunsoo on 4/23/25.
//

import SwiftUI

@main
struct TodoJsonApp: App {
    
    @StateObject private var todoStore = TodoStore(userId: "user1")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoStore)
        }
    }
}
