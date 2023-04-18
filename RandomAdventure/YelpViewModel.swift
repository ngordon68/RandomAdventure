//
//  YelpViewModel.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 3/26/23.
//

import Foundation
import Combine


//Bearer
//find a way to protect this key
let apiKey = "iTvzHsH40PlOzpMVv5IRKhWLaAyVYvZ3BAIxg8sR9GbgkpqvCUNEgbxouW6irhZlkTHAzRJOw1W1zMBNPEgAdE3z3dLrAzWyo-3U8sdJYF1oLg-7BMvXgTSEZCHhY3Yx"


@MainActor
class TestApi: ObservableObject {
    
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

    var adventures = [Adventure]()
    @Published var resultAdventures = [Adventure]()
    @Published var isLoading = false
    @Published var randomAdventure:Adventure? = nil//potentional issue
    @Published var firstAdventure:AdventureEnum = AdventureEnum.food
    @Published var searchTerm:String = ""
    var cancellables = Set<AnyCancellable>()
    var enumSearch = AdventureEnum.arcades.rawValue //maybe not updating fast enough
    

    func EnumConvert()  {
        enumSearch = firstAdventure.rawValue
    }
    
    
    func generateRandomAdventureList() async   {
        
            isLoading = true
        resultAdventures.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
            
            self.EnumConvert()
            self.getPosts(searchTerm: self.searchTerm, Genre: self.enumSearch)
            self.isLoading = false
        }
            
    }
    
    func getPosts(searchTerm:String = "United States", Genre:String = "Parks")    {
        
      
            let newURL = "https://api.yelp.com/v3/businesses/search"
            var urlComponents = URLComponents(string: newURL)!
            urlComponents.scheme = "https"
            urlComponents.host = "api.yelp.com"
            urlComponents.path = "/v3/businesses/search"
            
            let queryItems = [
                URLQueryItem(name: "location", value: searchTerm),
                URLQueryItem(name: "term", value: Genre)
            ]
            urlComponents.queryItems = queryItems
            
            var request = URLRequest(url: urlComponents.url!)
            
            
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            //combine workflow
            //create the publisher
            //put publisher on the background thread(subscribe publisher on background thread)
            //receive on main thead
            //tryMap(check that the data is good)
            //decode (decode data into Models)
            //sink (put the item into the app)
            //store (cancel subscription if needed)
            
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { (data, response) -> Data in
                    guard let response = response as? HTTPURLResponse,
                          response.statusCode >= 200 && response.statusCode < 300 else {
                        throw URLError(.badServerResponse)
                    }
                    //  print(data.description)
                    //this works!
                    
                    return data
                    
                }
                .decode(type: AdventureArray.self, decoder: JSONDecoder())
                .sink { (completion) in
                    
                    
                } receiveValue: { [weak self] (returnedWorkSpaces) in
                    guard let self = self, let businesses = returnedWorkSpaces.businesses else {
                        // Error handling
                        return
                    }
                    self.adventures = businesses
                    
                    if let randomAdventure = self.adventures.randomElement() {
                        self.resultAdventures.append(randomAdventure)
                        print("\(self.adventures.count)")
                        
                        
                        print(randomAdventure.name)
                    }
                
                }
                .store(in: &cancellables)
    
    }
}




