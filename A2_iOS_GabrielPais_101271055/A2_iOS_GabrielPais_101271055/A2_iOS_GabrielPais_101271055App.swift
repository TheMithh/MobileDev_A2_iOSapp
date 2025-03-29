//
//  A2_iOS_GabrielPais_101271055App.swift
//  A2_iOS_GabrielPais_101271055


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
