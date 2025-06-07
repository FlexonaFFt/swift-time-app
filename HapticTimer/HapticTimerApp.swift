//
//  HapticTimerApp.swift
//  HapticTimer
//
//  Created by Игорь Жаров on 07.06.2025.
//

import SwiftUI

@main
struct HapticTimerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
