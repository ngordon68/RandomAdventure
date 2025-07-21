//
//  MapView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 11/10/24.
//
import SwiftUI

import SwiftUI
import MapKit



struct MapView: View {
    @Environment(\.dismissSearch) var dismissSearch
    @FocusState private var isSearchFocused: Bool
    @State private var searchCategory:AdventureEnum = .bars
    @State private var userLocation = ""
    @State  var listOfAdventures: [MKMapItem]
    @State private var selection: MKMapItem?
    @State private var currentPlace: MKMapItem?
    @State private var  isShowingNoInternetAlert: Bool = false
    @State private var locationSearchServices = LocationSearchServices()
    @State private var isShowingSearchbar: Bool = false
 
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
            ZStack {
                Color(.primary)
                    .ignoresSafeArea()
                VStack {
                    
                    if !isSearchFocused  {
                        GroupBox {
                            HStack {
                                Text("Select Category:")
                                    .foregroundStyle(Color(.accent))
                                Picker("Mood", selection: $searchCategory) {
                                    ForEach(AdventureEnum.allCases, id: \.self) { mood in
                                        Text(mood.rawValue)
                                            .foregroundStyle(Color(.accent))
                                        
                                    }
                                }
                                .accentColor(Color(.accent))
                            }
                        }
                        .backgroundStyle(Color(.secondary))
                        
                        Button {
                            getCoordinate(addressString: userLocation) { coordinates, Error in
                                search(for: searchCategory.rawValue, coordinates: coordinates)
                            }
                        } label: {
                            Rectangle()
                                .frame(height: UIScreen.main.bounds.width * 0.15)
                                .frame(width: UIScreen.main.bounds.width * 0.45)
                                .cornerRadius(20)
                                .foregroundColor(Color(.secondary))
                                .overlay {
                                    Text("Find Adventure")
                                        .foregroundColor(Color(.accent))
                                        .tag(Color.red)
                                }
                        }
                        .padding()
                        
                        if listOfAdventures.isEmpty {
                            
                            Text("Select a genre to start your adventure!")
                                .font(.title)
                                .minimumScaleFactor(0.5)
                        }
                        
                        if listOfAdventures.count > 0 {
                            Text("Your adventure is to \n \(currentPlace?.placemark.name ?? "")!")
                                .font(.title)
                                .minimumScaleFactor(0.5)
                        }
                                                AdventureMapView(
                                                    cameraPosition: $cameraPosition,
                                                    bounds: mapBounds,
                                                    adventures: listOfAdventures,
                                                    selection: $selection
                                                )
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
                                                .alert("Please make sure you are connected to the internet", isPresented: $isShowingNoInternetAlert) {
                                                    Button("OK", role: .cancel) {
                                                    }
                                                }
                        
                    } else {
                        locationResults
                        
                    }
                }
            }
            .searchable(text: $locationSearchServices.query, isPresented: $isShowingSearchbar, placement: .navigationBarDrawer, prompt: Text("City Name"))
            .searchFocused($isSearchFocused)
            .onSubmit(of: .search) {
            
                Task {
                    getCoordinate(addressString: locationSearchServices.query) { coordinates, Error in
                        search(for: searchCategory.rawValue, coordinates: coordinates)
                    }
                    
                    locationSearchServices.query = ""
                    locationSearchServices.results = []

                        dismissSearch()
                        isSearchFocused = false
                        isShowingSearchbar = false
                }
                
            }
        }
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
                .foregroundStyle(Color(.text))
            }
        }
        
        .scrollContentBackground(.hidden)
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
}

#Preview {
    MapView(listOfAdventures: [])
}










