//
//  MapView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 11/10/24.
//
import SwiftUI
import MapKit
import FoundationModels

struct MapView: View {
    @AppStorage("lastRecommendationDate") private var lastRecommendationDate: Double = 0
    @Environment(\.scenePhase) private var scenePhase
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
    @State var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 42.3317, longitude: -83.0471),
            distance: 980,
            heading: 242,
            pitch: 60
        )
    )
    var mapBounds = MapCameraBounds(minimumDistance: 1000, maximumDistance: 2000)
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
                                .opacity(placeRecommendations.isEmpty ? 0 : 1)
                            
                            if placeRecommendations.isEmpty {
                                Rectangle()
                                    .frame(width: 350, height: 150)
                                    .cornerRadius(15)
                                    .foregroundStyle(Color(.secondary))
                                    .opacity(0)
                                    .overlay {
                                        Text("Just favorite a few spots to unlock personalized suggestions")
                                            .font(.title)
                                    }
                            } else {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(placeRecommendations, id: \.id) { place in
                                            Rectangle()
                                                .frame(width: 160, height: 150)
                                                .cornerRadius(15)
                                                .foregroundStyle(Color(.secondary))
                                                .overlay {
                                                    ZStack(alignment: .topTrailing) {
                                                        VStack(alignment: .leading, spacing: 8) {
                                                            Text(place.title)
                                                                .font(.headline)
                                                                .lineLimit(2)
                                                                .minimumScaleFactor(0.8)
                                                            
                                                            Text(place.subtitle)
                                                                .font(.caption)
                                                               // .foregroundStyle(.secondary)
                                                                .lineLimit(3)
                                                            
                                                            Spacer(minLength: 0)
                                                            
                                                            Button {
                                                                centerOnPlace(from: place)
                                                            } label: {
                                                                Label("Show on Map", systemImage: "map")
                                                                    .font(.caption)
                                                            }
                                                            .buttonStyle(.bordered)
                                                        }
                                                        .padding(10)
                                                        .foregroundStyle(Color(.customComponent))
                                                 
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                                
                        } else {
                            locationResults
                              
                            
                        }
                    }
                    .padding(.bottom, 30 )
                    
                }
            }
            .alert("Please make sure you are connected to the internet", isPresented: $isShowingNoInternetAlert) {
                Button("OK", role: .cancel) {
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
      
        .task {
            if isNewDaySinceLastRecommendation() {
                await generateAndSaveRecommendationIfNeeded()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, isNewDaySinceLastRecommendation() {
                Task { await generateAndSaveRecommendationIfNeeded() }
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
        
        if !userFavorites.isEmpty {
            print("starting recommendations")
            let instructions = """
        You are a travel agent with the goal of providing the best hidden gem places to the user.
          When providing a recommendation, include:
          - title: The name of the place
          - subtitle: A short description
        """
            
            //  let session = LanguageModelSession(instructions: instructions)
            
            //        let placeInfo = try await session.respond(
            //            to: """
            //        Please suggest a place to visit based on one of \(AdventureEnum.allCases) with a similar vibe to the user's favorites \(userFavorites), located in Detroit.
            //        """,
            //           generating: PlaceRecommendation.self
            //        )
            let session = LanguageModelSession(instructions: instructions)
            let placeInfo = try await session.respond(
                to: "Please suggest a place to visit that has a similiar vibe to the following items in the list \(userFavorites) and location within 10 miles.",
                generating: PlaceRecommendation.self
            )
            
            print("Title: \(placeInfo.content)")
            
            takeGeneratedRecommendationAndMakeMapItem(placeInfo: placeInfo.content.title)
            
        }
    }
    
    func takeGeneratedRecommendationAndMakeMapItem(placeInfo: String) {
        getCoordinate(addressString: placeInfo) { coordinates, Error in
          //  search(for: placeInfo, coordinates: (coordinates)) //maybe use enum
            search( coordinates: (coordinates), generatedPlaceName: placeInfo)
        }
    }
    
    func centerOnPlace(from recommendation: PlaceRecommendation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = recommendation.title
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.3317, longitude: -83.0471),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )

        Task {
            let search = MKLocalSearch(request: request)
            if let response = try? await search.start(),
               let item = response.mapItems.first {
                listOfAdventures = [item]
                currentPlace = item
                if let coordinate = item.placemark.location?.coordinate {
                    withAnimation(.easeInOut(duration: 0.8)) {
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
            } else {
                isShowingNoInternetAlert = true
            }
        }
    }

    func openInMaps(from recommendation: PlaceRecommendation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = recommendation.title
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 42.3317, longitude: -83.0471),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )

        Task {
            let search = MKLocalSearch(request: request)
            if let response = try? await search.start(),
               let item = response.mapItems.first {
                item.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            } else {
                isShowingNoInternetAlert = true
            }
        }
    }
    private func isNewDaySinceLastRecommendation() -> Bool {
        let last = Date(timeIntervalSince1970: lastRecommendationDate)
        return !Calendar.current.isDateInToday(last)
    }

    private func generateAndSaveRecommendationIfNeeded() async {
        guard isNewDaySinceLastRecommendation() else { return }
        do {
            try await generateRecommendations()
            lastRecommendationDate = Date().timeIntervalSince1970
        } catch {
            // Optionally handle/log the error
        }
    }
}

#Preview {
    MapView(listOfAdventures: [])
}

extension PlaceRecommendation: Identifiable {
    public var id: String { "\(title)|\(subtitle)" }
}

