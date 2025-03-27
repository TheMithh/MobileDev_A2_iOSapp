//
//  A2_iOS_GabrielPais_101271055App.swift
//  A2_iOS_GabrielPais_101271055
//
//  Created by viorel pais on 2025-03-27.
//

import SwiftUI

@main
struct A2_iOS_GabrielPais_101271055App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
