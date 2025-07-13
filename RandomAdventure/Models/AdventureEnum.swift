//
//  AdventureEnum.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 11/23/24.
//

enum AdventureEnum: String, CaseIterable {
    case food = "food"
    case musuems = "musuems"
    case parks = "parks"
    case entertainment = "entertainment"
    case bars = "bars"
    case movies = "movies"
    case arcades = "arcades"
    
    var emoji:String {
        switch self {
        case.food:
            return "food"
        case.musuems:
            return "musuems"
        case.parks:
            return "parks"
        case.entertainment:
            return "entertainment"
        case.bars:
            return "bars"
        case.movies:
            return "movies"
        case.arcades:
            return "arcades"
        }
    }
}

