//
//  MapView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 11/10/24.
//
import SwiftUI
import MapKit
//import FoundationModels

struct MapView: View {
    @Environment(\.openURL) var openURL
    @State var mapkitManager = MapkitManager(listOfAdventures: [])
    @State var locationSearchServices = LocationSearchServices()
    @StateObject private var locationManager = LocationManager()
    @State private var didPressFavoriteButton: Bool = false
    @State private var favoriteBannerTask: Task<Void, Never>? = nil
    @State var isShowingMapSheet: Bool = true
    @State private var selectedDetent: PresentationDetent = .fraction(0.40)
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
            AdventureMapView(
                cameraPosition: $cameraPosition,
                bounds: mapBounds,
                adventures: mapkitManager.listOfAdventures,
                selection: $mapkitManager.selection
            )
            .animation(.smooth(duration: 0.8), value: cameraPosition)
            .onChange(of: mapkitManager.currentPlace) { _, selection in
                guard let coordinate = selection?.placemark.coordinate else { return }
                cameraPosition = .camera(
                    MapCamera(
                        centerCoordinate: coordinate,
                        distance: 980,
                        heading: 242,
                        pitch: 60
                    )
                )
            }
            .overlay(alignment: .top) {
                if didPressFavoriteButton {
                    FavoriteAnimationView()
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: didPressFavoriteButton)

            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                     //   locationManager.fetchUserLocation()

                    } label: {
                        Image(systemName: locationManager.isAuthorizedForLocation ?  "location" : "location.slash")
                    }
                 
                    
                }

                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if mapkitManager.addToFavorites() {
                            showFavoriteAnimation()
//                            Task {
//                                try? await  mapkitManager.generateRecommendations()
//                            }
                           
                        }
                      
                    } label: {
                        Image(systemName: "heart")
                    }
                    .sensoryFeedback(.success, trigger: didPressFavoriteButton)
                  
                }

            }
           
        }
        .alert("Please make sure you are connected to the internet", isPresented:  $mapkitManager.isShowingNoInternetAlert) {
            Button("OK", role: .cancel) {
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
        .sheet(isPresented: $isShowingMapSheet) {
            InformationView(locationSearchServices: locationSearchServices, mapkitManager: mapkitManager, cameraPosition: $cameraPosition, selectedDetent: $selectedDetent)
            .presentationBackgroundInteraction(.enabled)
            .presentationDragIndicator(.visible)
           .interactiveDismissDisabled()
           .presentationDetents([.fraction(0.40), .large], selection: $selectedDetent)
        }
    }
    
    @MainActor
    func showFavoriteAnimation() {
       // mapkitManager.addToFavorites()
        favoriteBannerTask?.cancel()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            didPressFavoriteButton = true
        }
        favoriteBannerTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeOut(duration: 0.3)) {
                didPressFavoriteButton = false
            }
        }
    }
}

#Preview {
    MapView()

}
