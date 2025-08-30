//
//  HundredsApp.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI

@main
struct HundredsApp: App {
    let dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}