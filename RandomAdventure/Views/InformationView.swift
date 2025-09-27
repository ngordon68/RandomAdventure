//
//  InformationView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 9/22/25.
//

import SwiftUI
import MapKit

struct InformationView: View {
    
    @Bindable var locationSearchServices: LocationSearchServices
    @Bindable var mapkitManager: MapkitManager
    @FocusState private var isSearchFocused: Bool
    
    @Binding var cameraPosition: MapCameraPosition
    
    @Binding var selectedDetent: PresentationDetent
    var body: some View {
        
        switch selectedDetent {
        case .fraction(0.40):
            smallSheetView
        case .large:
            largeSheetView
        default:
            EmptyView()
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
                .foregroundStyle(Color(.customText))
            }
        }
        .scrollContentBackground(.hidden)
        
    }
    
    var smallSheetView: some View {
        NavigationStack {
            GeometryReader { geometry in
                if !isSearchFocused {
                    ScrollView {
                        VStack {
                            HStack {
                                Spacer()
                                GroupBox {
                                    HStack {
                                        Text("Category:")
                                        
                                            .bold()
                                        Picker("Select Category", selection: $mapkitManager.searchCategory) {
                                            ForEach(AdventureEnum.allCases, id: \.self) { mood in
                                                Text(mood.rawValue)
                                            }
                                        }
                                        
                                    }
                                }
                                .backgroundStyle(Color(.primary))
                                
                                
                                Button {
                                    mapkitManager.getCoordinate(addressString: locationSearchServices.query) { coordinates, Error in
                                        mapkitManager.search(for:  mapkitManager.searchCategory.rawValue, coordinates: (coordinates))
                                    }
                                } label: {
                                    Text("Find")
                                        .font(.headline)
                                    // .foregroundStyle(Color(.customComponent))
                                        .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.15)
                                        .background(Color(.primary))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color(.customText).opacity(0.7), lineWidth: 5)
                                        )
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                                }
                                .padding()
                                
                                Spacer()
                            }
                            Text("Swipe up for more")
                                .font(.title)
                                .bold()
                        }
                    }
                } else {
                    locationResults
                }
            }
            .searchable(text: $locationSearchServices.query, isPresented: $locationSearchServices.isShowingSearchbar, placement: .navigationBarDrawer, prompt: "Enter City")
            .searchFocused($isSearchFocused)
            .onSubmit(of: .search) {
                Task {
                    mapkitManager.getCoordinate(addressString: locationSearchServices.query) { coordinates, Error in
                        mapkitManager.search(for:  mapkitManager.searchCategory.rawValue, coordinates: coordinates)
                    }
                    locationSearchServices.results = []
                    locationSearchServices.isShowingSearchbar = false
                }
                
            }
        }
    }
    var largeSheetView: some View {
        NavigationStack {
            GeometryReader { geometry in
                if !isSearchFocused {
                    ScrollView {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                GroupBox {
                                    HStack {
                                        Text("Category:")
                                        
                                            .bold()
                                        Picker("Select Category", selection: $mapkitManager.searchCategory) {
                                            ForEach(AdventureEnum.allCases, id: \.self) { mood in
                                                Text(mood.rawValue)
                                            }
                                        }
                                        
                                    }
                                }
                                .backgroundStyle(Color(.primary))
                                
                                
                                Button {
                                    mapkitManager.getCoordinate(addressString: locationSearchServices.query) { coordinates, Error in
                                        mapkitManager.search(for:  mapkitManager.searchCategory.rawValue, coordinates: (coordinates))
                                    }
                                } label: {
                                    Text("Find")
                                        .font(.headline)
                                        .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.15)
                                        .background(Color(.primary))
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color(.customText).opacity(0.7), lineWidth: 5)
                                        )
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                                }
                                .padding()
                                
                                Spacer()
                            }
                            Text("You may also like")
                                .font(.title)
                                .bold()
                                .opacity(mapkitManager.placeRecommendations.isEmpty ? 0 : 1)
                                .padding(.horizontal)
                            
                            if mapkitManager.placeRecommendations.isEmpty {
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
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(mapkitManager.placeRecommendations, id: \.id) { place in
                                            PlaceCard(
                                                title: place.title,
                                                subtitle: place.subtitle,
                                                onPrimaryAction: {
                                                    selectedDetent = .fraction(0.40)
                                                    centerOnPlace(from: place)
                                                },
                                                onAccessoryAction: {
                                                    mapkitManager.placeRecommendations.removeAll { $0.title == place.title }
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            Text("Favorites")
                                .font(.title)
                                .bold()
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(mapkitManager.userFavorites) { favorite in
                                        PlaceCard(
                                            title: favorite.title,
                                            subtitle: favorite.subtitle,
                                            onPrimaryAction: {
                                                selectedDetent = .fraction(0.40)
                                                centerOnPlace(from: favorite)
                                            },
                                            onAccessoryAction: {
                                                mapkitManager.userFavorites.removeAll { $0.title == favorite.title }
                                            }
                                        )
                                    }
                                }
                            }
                            
                            
                        }
                        
                    }
                } else {
                    locationResults
                }
            }
            .searchable(text: $locationSearchServices.query, isPresented: $locationSearchServices.isShowingSearchbar, placement: .navigationBarDrawer, prompt: "Enter City")
            .searchFocused($isSearchFocused)
            .onSubmit(of: .search) {
                Task {
                    mapkitManager.getCoordinate(addressString: locationSearchServices.query) { coordinates, Error in
                        mapkitManager.search(for:  mapkitManager.searchCategory.rawValue, coordinates: coordinates)
                    }
                    locationSearchServices.results = []
                    locationSearchServices.isShowingSearchbar = false
                }
                
            }
        }
        
        
    }
    
    
    func centerOnPlace(from recommendation: any LocationResultModel) {
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
                mapkitManager.listOfAdventures = [item]
                mapkitManager.currentPlace = item
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
                mapkitManager.isShowingNoInternetAlert = true
            }
        }
    }
    
}

#Preview {
    InformationView( locationSearchServices: LocationSearchServices(), mapkitManager: MapkitManager(listOfAdventures: []), cameraPosition: .constant(.automatic), selectedDetent: .constant(.large))
}


