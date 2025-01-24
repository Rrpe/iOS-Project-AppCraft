//
//  BusinessCardApp.swift
//  BusinessCard
//
//  Created by KimJunsoo on 1/21/25.
//

import SwiftUI
import SwiftData

@main
struct BusinessCardApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CardData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
