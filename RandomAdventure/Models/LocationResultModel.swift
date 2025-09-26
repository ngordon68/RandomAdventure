//
//  LocationResultModel.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 12/3/24.
//

import Foundation
import FoundationModels

protocol LocationResultModel: Identifiable, Hashable {
    var id: String { get }
    var title: String { get }
    var subtitle: String { get }
    var isFavorite: Bool { get set }
}

struct LocationResult: LocationResultModel{
    var id: String = UUID().uuidString
    var title: String
    var subtitle: String
    var isFavorite: Bool = false
    
}

@Generable
struct PlaceRecommendation: LocationResultModel {
    var title: String
    var subtitle: String
//    
//    @Guide(description: "Address of the recommendation, make the address in the shortest possible format")
//    var address: String
    var isFavorite: Bool = false
}


