//
//  MapView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 11/10/24.
//
import SwiftUI

import SwiftUI
import MapKit
import FoundationModels

struct MapView: View {
    @State private var locationSearchServices = LocationSearchServices()
    @StateObject private var locationManager = LocationManager()
    @Environment(\.dismissSearch) var dismissSearch
    @Environment(\.openURL) var openURL
    @FocusState private var isSearchFocused: Bool
    @State private var searchCategory:AdventureEnum = .food
    @State  var listOfAdventures: [MKMapItem]
    @State private var selection: MKMapItem?
    @State private var currentPlace: MKMapItem?
    @State private var  isShowingNoInternetAlert: Bool = false
    @State private var isShowingSearchbar: Bool = false
    @State private var isShowingFavoritesSheet: Bool = false
    @State private var userFavorites: [LocationResult] = []
    @State private var placeRecommendations: [PlaceRecommendation] = []
    
    var mapBounds = MapCameraBounds(minimumDistance: 1000, maximumDistance: 2000)
    
    @State var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 42.3317, longitude: -83.0471),
            distance: 980,
            heading: 242,
            pitch: 60
        )
    )
    
    let columns = [
        GridItem(.fixed(100)),
        GridItem(.flexible()),
    ]
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color(.primary)
                      .ignoresSafeArea()
                    VStack {
                    
                        if !isSearchFocused  {
                            GroupBox {
                                HStack {
                                    Text("Category:")
                                        .foregroundStyle(Color(.customComponent))
                                        .bold()
                                    Picker("Select Category", selection: $searchCategory) {
                                        ForEach(AdventureEnum.allCases, id: \.self) { mood in
                                            Text(mood.rawValue)
                                        }
                                    }
                                    .accentColor(Color(.customComponent))
                                }
                            }
                            .backgroundStyle(Color(.secondary))
                            //.padding(.top, 10)
                          //  .glassEffect()
                            
                            
    
                            Button {
                                getCoordinate(addressString: locationSearchServices.query) { coordinates, Error in
                                    search(for: searchCategory.rawValue, coordinates: (coordinates))
                                }
                            } label: {
                                Text("Find Adventure")
                                    .font(.headline)
                                    .foregroundStyle(Color(.customComponent))
                                    .frame(width: geometry.size.width * 0.45, height: geometry.size.width * 0.15)
                                    .background(Color(.secondary))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.7), lineWidth: 5)
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                            }
                            .padding()
                       
                            
                            AdventureMapView(
                                cameraPosition: $cameraPosition,
                                bounds: mapBounds,
                                adventures: listOfAdventures,
                                selection: $selection
                            )
                            .cornerRadius(15)
                            .background {
                                Rectangle()
                                    .frame(width: geometry.size.width * 0.93, height: geometry.size.width * 0.7)
                                    .foregroundStyle(Color(.secondary))
                                    .cornerRadius(15)
                                    .overlay(alignment: .topTrailing) {
                                        Button(action: {
                                            addToFavorites()
                                        }, label: {
                                            Image(systemName: "heart.circle")
                                                .foregroundStyle(.pink)
                                                .font(.title)
                                                .padding(5)
                                        })
                                      //  .buttonStyle(.glass)
                                      
                                        
                                    }
                            }
                            .padding(geometry.size.width * 0.1)
                            .frame(maxHeight: .infinity) // Keep it full height
                            .toolbarBackground(Color(.primary), for: .navigationBar)
                            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
                            .onChange(of: currentPlace) { _, selection in
                                if let coordinate = selection?.placemark.coordinate {
                                    withAnimation(.easeInOut(duration: 1.0)) { // Adjust the animation style and duration as needed
                                        cameraPosition = .camera(
                                            MapCamera(
                                                centerCoordinate: coordinate,
                                                distance: 980,
                                                heading: 242,
                                                pitch: 60
                                            )
                                        )
                                    }
                                }
                            }
                            Text("You may also like")
                                .font(.title)
                                .bold()
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(0..<4) { index in
                                        Rectangle()
                                            .frame(width: 150, height: 150)
                                            .cornerRadius(15)
                                            .foregroundStyle(Color(.secondary))
                                            .overlay {
                                                Text("Some content")
                                                    .foregroundStyle(Color(.customComponent))
                                            }
                                        
                                    }
                                }
                            }
                            .alert("Please make sure you are connected to the internet", isPresented: $isShowingNoInternetAlert) {
                                Button("OK", role: .cancel) {
                                }
                            }
                            
                        } else {
                            locationResults
                              
                            
                        }
                    }
                    .padding(.bottom, 30 )
                    
                }
            }
            
            .toolbar {
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                     //   locationManager.fetchUserLocation()
                    
                        
                        Task {
                          try await generateRecommendations()
                        }
                    } label: {
                        Image(systemName: locationManager.isAuthorizedForLocation ?  "location" : "location.slash")
                    }
                    //.font(.title)
                    //.buttonStyle(.glass)
                  //  .foregroundStyle(Color(.secondary))
                }
          
                           ToolbarSpacer(.flexible, placement: .bottomBar)
                
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                
                ToolbarSpacer(.flexible, placement: .bottomBar)
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isShowingFavoritesSheet.toggle()
                    } label: {
                        Image(systemName: "heart")
                           // .foregroundStyle(Color(.secondary))
                    }
                    .font(.title)
                   // .buttonStyle(.glass)
                }

            }
           
        }
     
    
        .alert("Location access denied. Please go to your settings and allow location access", isPresented: $locationManager.isShowingDeniedAlert) {
            Button("Settings", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .tint(.primary)
            .foregroundStyle(Color(.secondary))
            Button("Cancel", role: .cancel) {}
                .tint(.primary)
            
        }
        .sheet(isPresented: $isShowingFavoritesSheet) {
            FavoritesView(userFavorites: $userFavorites)
        }
     
        
        .searchable(text: $locationSearchServices.query, isPresented: $isShowingSearchbar, placement: .navigationBarDrawer, prompt: Text("City Name"))
        .searchFocused($isSearchFocused)
  
        .onSubmit(of: .search) {
            Task {
                getCoordinate(addressString: locationSearchServices.query) { coordinates, Error in
                    search(for: searchCategory.rawValue, coordinates: coordinates)
                }
                locationSearchServices.results = []
                isShowingSearchbar = false
            }
            
        }
       // .searchToolbarBehavior(.minimize)
       
     
    }
    
    var locationResults: some View {
        List(locationSearchServices.results) { location in
            
            Button {
                locationSearchServices.query = location.title
            } label: {
                VStack(alignment: .leading) {
                    Text(location.title)
                    Text(location.subtitle)
                }
                .foregroundStyle(Color(.customText))
           
            }
          
        }
        
        .scrollContentBackground(.hidden)
     //   .glassEffect()
    }
    
    func search(for query: String, coordinates: CLLocationCoordinate2D) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
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
                currentPlace = singleAdventure
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
    func addToFavorites() {
        let generator = UINotificationFeedbackGenerator()
        guard let place = currentPlace?.placemark else { return }
         let verifiedTitle = place.name ?? "Unknown Place"
         let verifiedSubtitle = place.subtitle ?? ""
         let newItem = LocationResult(title: verifiedTitle, subtitle: verifiedSubtitle, isFavorite: true)
        
        if userFavorites.contains(where: { $0.title == verifiedTitle }) {
            print("item already exist")
            return
        } else {
            userFavorites.append(newItem)
            generator.notificationOccurred(.success)
        }
    }
    
    func generateRecommendations() async throws  {
    print("starting recommendations")
        let instructions = "You are an travel agent with the goal of providing the best experience to the user. Please suggest a place to visit that has a similiar vibe to the following items in the list... \(userFavorites) and in Detroit"
        let session = LanguageModelSession(instructions: instructions)
        let placeInfo = try await session.respond(
            to: "Suggest a place to visit that has a similiar vibe to the following items in the list... \(userFavorites)",
            generating: PlaceRecommendation.self
        )
        print("Title: \(placeInfo.content)")
    }
    
    
}

#Preview {
    MapView(listOfAdventures: [])
}









