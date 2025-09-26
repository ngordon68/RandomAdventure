//
//  MapkitManager.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 9/22/25.
//

import Foundation
import MapKit
import CoreLocation
import Observation
import FoundationModels

@MainActor
@Observable
class MapkitManager {
    
    var listOfAdventures: [MKMapItem]
    var selection: MKMapItem?
    var currentPlace: MKMapItem?
    var  isShowingNoInternetAlert: Bool = false
    var userFavorites: [LocationResult] = []
    var placeRecommendations: [PlaceRecommendation] = [
PlaceRecommendation(title: "This is the song that never ends", subtitle: "it goes on and on my friend"),
PlaceRecommendation(title: "This is the song that never ends", subtitle: "it goes on and on my friend"),
PlaceRecommendation(title: "This is the song that never ends", subtitle: "it goes on and on my friend"),
PlaceRecommendation(title: "This is the song that never ends", subtitle: "it goes on and on my friend"),
PlaceRecommendation(title: "This is the song that never ends", subtitle: "it goes on and on my friend")
    ]
    
    var searchCategory:AdventureEnum = .food
    
    
    
    init(listOfAdventures: [MKMapItem]) {
        self.listOfAdventures = listOfAdventures
      
    }
    
    func search(for query: String? = nil, coordinates: CLLocationCoordinate2D, generatedPlaceName: String? = nil) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query ?? generatedPlaceName
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion (
            
            center: coordinates   ,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            
            
                listOfAdventures = response?.mapItems ?? []
                if let singleAdventure = listOfAdventures.randomElement() {
                    listOfAdventures.append(singleAdventure)
                    listOfAdventures.removeAll(where: { $0 != singleAdventure})
                    listOfAdventures.removeLast()
                    if query != nil {
                        currentPlace = singleAdventure
                    }
                    
                    if generatedPlaceName != nil {
                        let placeResult = listOfAdventures.map { PlaceRecommendation(title: $0.name ?? "No name Available", subtitle: $0.address?.fullAddress ?? "no address available") }
                        
                        placeRecommendations.append(placeResult[0])
                    }
                    
                } else {
                    isShowingNoInternetAlert = true
                }
            
            
        
        }
    }
    
     func getCoordinate( addressString : String,
                        completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func addToFavorites() -> Bool {
        let generator = UINotificationFeedbackGenerator()
        guard let place =  currentPlace?.placemark else { return false }
         let verifiedTitle = place.name ?? "Unknown Place"
         let verifiedSubtitle = place.subtitle ?? ""
         let newItem = LocationResult(title: verifiedTitle, subtitle: verifiedSubtitle, isFavorite: true)
        
        if userFavorites.contains(where: { $0.title == verifiedTitle }) {
            print("item already exist")
            return false
        } else {
            userFavorites.append(newItem)
            generator.notificationOccurred(.success)
            return true
        }
    }
    
    
    
    func generateRecommendations() async throws  {
        
        if !userFavorites.isEmpty {
            print("starting recommendations")
            let instructions = """
        You are a travel agent with the goal of providing the best hidden gem places to the user.
          When providing a recommendation, include:
          - title: The name of the place
          - subtitle: A short description
        """
            
//              let session = LanguageModelSession(instructions: instructions)
//            
//                    let placeInfo = try await session.respond(
//                        to: """
//                    Please suggest a place to visit based on one of \(AdventureEnum.allCases) with a similar vibe to the user's favorites \(userFavorites), located in Detroit.
//                    """,
//                       generating: PlaceRecommendation.self
//                    )
            let session = LanguageModelSession(instructions: instructions)
            let placeInfo = try await session.respond(
                to: "Please suggest a place to visit that has a similiar vibe to the following items in the list \(userFavorites) and location within 10 miles.",
                generating: PlaceRecommendation.self
            )
            
            print("Title: \(placeInfo.content)")
            
            takeGeneratedRecommendationAndMakeMapItem(placeInfo: placeInfo.content.title)
            
        }
    }
   
  private func takeGeneratedRecommendationAndMakeMapItem(placeInfo: String) {
        getCoordinate(addressString: placeInfo) { coordinates, Error in
          //  search(for: placeInfo, coordinates: (coordinates)) //maybe use enum
            self.search( coordinates: (coordinates), generatedPlaceName: placeInfo)
        }
    }
    
    
    
}

