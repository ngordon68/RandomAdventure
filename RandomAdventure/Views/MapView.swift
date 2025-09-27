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
    @AppStorage("lastRecommendationDate") private var lastRecommendationDate: Double = 0
    @Environment(\.scenePhase) private var scenePhase
    @State var locationSearchServices = LocationSearchServices()
    @StateObject private var locationManager = LocationManager()
    @Environment(\.openURL) var openURL
    @State private var didPressFavoriteButton: Bool = false
    @State private var favoriteBannerTask: Task<Void, Never>? = nil
    @State var isShowingMapSheet: Bool = true
    @State var mapkitManager = MapkitManager(listOfAdventures: [])
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
                    HStack(spacing: 10) {
                        Image(systemName: "heart.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, options: .repeat(1)) // fun, subtle bounce

                        Text("Added to Favorites")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        // Glassy capsule-style background
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .foregroundStyle(Color.black.opacity(0.35))
                            .glassEffect()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                    .shadow(color: .black.opacity(0.25), radius: 20, y: 12)
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .allowsHitTesting(false) // don't intercept touches
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
                            Task {
                                try? await  mapkitManager.generateRecommendations()
                            }
                           
                        }
                      
                    } label: {
                        Image(systemName: "heart")
                    }
                    //.sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: counter)
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
                mapkitManager.isShowingNoInternetAlert = true
            }
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
