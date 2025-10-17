//
//  LocationResultModel.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 12/3/24.
//

import Foundation
import FoundationModels
import SwiftData

protocol LocationResultModel: Identifiable, Hashable {
    var id: String { get }
    var title: String { get }
    var subtitle: String { get }
    var isFavorite: Bool { get set }
}

@Model
class LocationResult: LocationResultModel{
    var id: String = UUID().uuidString
    var title: String
    var subtitle: String
    var isFavorite: Bool = false

    init(id: String = UUID().uuidString, title: String, subtitle: String, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isFavorite = isFavorite
    }
    
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

