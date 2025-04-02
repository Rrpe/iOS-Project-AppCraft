//
//  MacroControllerMacApp.swift
//  MacroControllerMac
//
//  Created by KimJunsoo on 3/26/25.
//

import SwiftUI

@main
struct MacroControllerMacApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
