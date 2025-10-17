//
//  RandomAdventureApp.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 3/26/23.
//

import SwiftUI
import SwiftData

@main
struct RandomAdventureApp: App {
    var body: some Scene {
        WindowGroup {
            MapView()
         
        }
        .modelContainer(for: LocationResult.self)
    }
}
