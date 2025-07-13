////
////  AppIntentsFile.swift
////  RandomAdventure
////
////  Created by Nick Gordon on 11/16/24.
////
//
//import Foundation
//import AppIntents
//
//
////struct Soup: AppEntity {
////   
////    
////   let id: String
////
////
////   @Property(title: "Type of Adventure")
////    let type: AdventureEnum = .bars
////}
////
////
//struct AdventureQuery: EntityQuery{
//    
//
//}
//
//extension AdventureQuery: EnumerableEntityQuery {
//    func allAdventures() async throws -> [AdventureEntity] {
//        
//    }
//}
//
//struct AdventureEntity: AppEntity {
//    
//    @Property(title: "Adventure Type")
//    var name: String
//    
//    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Adventure"
//    
//    var displayRepresentation: DisplayRepresentation {
//        DisplayRepresentation(title: "Adventure")
//    }
//    var id: String { name }
//    
//    static var defaultQuery = AdventureQuery()
//}
//struct RandomAdventureAppIntent: AppIntent, OpenIntent {
//   
//    
//    
//    static let title = LocalizedStringResource("Find An Adventure")
//    static let description = "Search for a random adventure"
//    
//    
//   
//    
//    @Parameter(title: "Random Adventure")
//    var target: AdventureEntity
//    
//    func perform() async throws -> some IntentResult {
//        
//        
//    
//        return .result(dialog: "Okay Nick I opened your app")
//    }
//    
//    @Dependency var adventure:AdventureEnum
//    
//   
//}
//
//
//struct RandomAdventureAppShortcut: AppShortcutsProvider {
//    static var appShortcuts: [AppShortcut]  {
//        
//        AppShortcut(
//            intent: RandomAdventureAppIntent(),
//            phrases: ["Find Random Adventure"]
//            )
//            }
//}
