//
//  FavoritesView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 8/27/25.
//

import SwiftUI

struct FavoritesView: View {
    var userFavorites: [LocationResult]
    
    var body: some View {
        ZStack {
            Color(.primary)
                .ignoresSafeArea()
            VStack {
                
                Text("Favorites")
                ForEach(userFavorites) { favorite in
                    
                    Rectangle()
                        .cornerRadius(15)
                        .foregroundStyle(Color(.secondary))
                        .overlay(alignment: .center) {
                            VStack {
                                Text(favorite.title)
                                Text(favorite.subtitle)
                            }
                            .foregroundStyle(Color(.customComponent))
                           
                            
                        }
                    
                }
                .font(.largeTitle)
                .bold()
            }
            .padding()
        }
    }
}

#Preview {
    FavoritesView(userFavorites: [
        
        LocationResult(title: "Test Title", subtitle: "Test Subtitle"),
        LocationResult(title: "Test Title", subtitle: "Test Subtitle"),
        LocationResult(title: "Test Title", subtitle: "Test Subtitle"),
        LocationResult(title: "Test Title", subtitle: "Test Subtitle"),
        LocationResult(title: "Test Title", subtitle: "Test Subtitle")
    ])
}
