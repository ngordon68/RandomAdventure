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
        //   .glassEffect()
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
                                        // .foregroundStyle(Color(.customComponent))
                                            .bold()
                                        Picker("Select Category", selection: $mapkitManager.searchCategory) {
                                            ForEach(AdventureEnum.allCases, id: \.self) { mood in
                                                Text(mood.rawValue)
                                            }
                                        }
                                        // .accentColor(Color(.customComponent))
                                    }
                                }
                                .backgroundStyle(Color(.primary))
                                //                                .overlay(
                                //                                    RoundedRectangle(cornerRadius: 20)
                                //                                        .stroke(Color(.customText).opacity(0.7), lineWidth: 5)
                                //                                )
                                //                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                                
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
                                        // .foregroundStyle(Color(.customComponent))
                                            .bold()
                                        Picker("Select Category", selection: $mapkitManager.searchCategory) {
                                            ForEach(AdventureEnum.allCases, id: \.self) { mood in
                                                Text(mood.rawValue)
                                            }
                                        }
                                        // .accentColor(Color(.customComponent))
                                    }
                                }
                                .backgroundStyle(Color(.primary))
                                //                                .overlay(
                                //                                    RoundedRectangle(cornerRadius: 20)
                                //                                        .stroke(Color(.customText).opacity(0.7), lineWidth: 5)
                                //                                )
                                //                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 3)
                                
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
                            Text("You may also like")
                                .font(.title)
                                .bold()
                                .opacity(mapkitManager.placeRecommendations.isEmpty ? 0 : 1)
                                .padding(.horizontal)

                            if mapkitManager.placeRecommendations.isEmpty {
                                // Keep your empty state as-is, or use a friendlier card with an icon
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
                            
//                            Text("You may also like")
//                                .font(.title)
//                                .bold()
//                                .opacity(mapkitManager.placeRecommendations.isEmpty ? 0 : 1)
//                                .padding(.horizontal)
//                            
//                            if mapkitManager.placeRecommendations.isEmpty {
//                                Rectangle()
//                                    .frame(width: 350, height: 150)
//                                    .cornerRadius(15)
//                                    .foregroundStyle(Color(.secondary))
//                                    .opacity(0)
//                                    .overlay {
//                                        Text("Just favorite a few spots to unlock personalized suggestions")
//                                            .font(.title)
//                                    }
//                            } else {
//                                ScrollView(.horizontal) {
//                                    HStack {
//                                        ForEach(mapkitManager.placeRecommendations, id: \.id) { place in
//                                            Rectangle()
//                                                .frame(width: 160, height: 150)
//                                              //  .frame(width: geometry.size * 2)
//                                                .cornerRadius(15)
//                                                .foregroundStyle(Color(.secondary))
//                                                .overlay(alignment: .topTrailing) {
//                                            Button(action: {
//                                                mapkitManager.placeRecommendations.removeAll(where: { $0.title == place.title })
//                                            }, label: {
//                                                Image(systemName: "trash.circle")
//                                                    .foregroundStyle(Color(.customComponent))
//                                                    .font(.title)
//                                                // .padding(3)
//                                            })
//                                        }
//                                            
//                                                .overlay {
//                                                    ZStack(alignment: .topTrailing) {
//                                                        VStack(alignment: .leading, spacing: 8) {
//                                                            Text(place.title)
//                                                                .font(.headline)
//                                                                .lineLimit(2)
//                                                                .minimumScaleFactor(0.8)
//                                                            
//                                                            Text(place.subtitle)
//                                                                .font(.caption)
//                                                            // .foregroundStyle(.secondary)
//                                                                .lineLimit(3)
//                                                            
//                                                            Spacer(minLength: 0)
//                                                            
//                                                            Button {
//                                                                selectedDetent = .fraction(0.40)
//                                                                centerOnPlace(from: place)
//                                                            } label: {
//                                                                Label("Show on Map", systemImage: "map")
//                                                                    .font(.caption)
//                                                            }
//                                                            .buttonStyle(.bordered)
//                                                        }
//                                                        .padding(10)
//                                                        .foregroundStyle(Color(.customComponent))
//                                                        
//                                                    }
//                                                }
//                                        }
//                                    }
//                                }
//                            }
//                            
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
                                            .overlay {
                                                ZStack(alignment: .topTrailing) {
                                                    VStack() {
                                                        Text(favorite.title)
                                                            .font(.headline)
                                                            .lineLimit(2)
                                                            .padding()
                                                        
                                                        // Spacer()
                                                        
                                                        Text(favorite.subtitle)
                                                            .font(.caption)
                                                            .foregroundStyle(.secondary)
                                                            .lineLimit(3)
                                                        //  .padding()
                                                        
                                                        Button {
                                                          selectedDetent = .fraction(0.40)
                                                          centerOnPlace(from: favorite)
                                                        } label: {
                                                            Label("Show on Map", systemImage: "map")
                                                                .font(.caption)
                                                        }
                                                        .buttonStyle(.bordered)
                                                        
                                                        
                                                    }
                                                    .font(.largeTitle)
                                                    .bold()
                                                    .minimumScaleFactor(0.8)
                                                    .foregroundStyle(Color(.customComponent))
                                                    
                                                }
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


extension PlaceRecommendation: Identifiable {
    public var id: String { "\(UUID().uuidString)" }
}


import SwiftUI

struct PlaceCard: View {
    let title: String
    let subtitle: String
    var actionTitle: String = "Show on Map"
    var actionIcon: String = "map"
    var accessoryIcon: String? = "trash.circle.fill" // set to nil to hide
    var accessoryRole: ButtonRole? = .destructive

    var onPrimaryAction: () -> Void
    var onAccessoryAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Optional top row with accessory action
            HStack(alignment: .top) {
                // Leading category/icon placeholder if you want one:
                Image(systemName: "mappin.and.ellipse")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color(.blue))
                    .accessibilityHidden(true)

                Spacer()

                if let accessoryIcon, let onAccessoryAction {
                    Button(role: accessoryRole) {
                        onAccessoryAction()
                    } label: {
                        Image(systemName: accessoryIcon)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .accessibilityLabel(Text("Remove"))
                }
            }

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Spacer(minLength: 0)

            Button(action: onPrimaryAction) {
                Label(actionTitle, systemImage: actionIcon)
                    .font(.caption)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .accessibilityHint(Text("Shows this place on the map"))
        }
        .padding(12)
        .frame(width: 200, height: 160) // tweak as desired
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

