//
//  AdventureMapView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 7/16/25.
//

import SwiftUI
import MapKit

struct AdventureMapView: View {
    @Binding var cameraPosition: MapCameraPosition
    let bounds: MapCameraBounds
    let adventures: [MKMapItem]
    @Binding var selection: MKMapItem?

    var body: some View {
        Map(position: $cameraPosition, bounds: bounds, selection: $selection) {
            ForEach(adventures, id: \.self) { store in
                Marker(item: store)
                    .annotationTitles(.visible)
            }
            .mapItemDetailSelectionAccessory(.sheet)
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
    }
}


