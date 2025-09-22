//
//  FavoritesView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 8/27/25.
//

import SwiftUI

struct FavoritesView: View {
    @Binding var userFavorites: [LocationResult]
    
    var body: some View {
       
            ZStack {
                Color(.primary)
                    .ignoresSafeArea()
                VStack {
                    
                    Text("Favorites")
                        .font(.largeTitle)
                    
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        let height = proxy.size.height
                        ScrollView {
                            ForEach(userFavorites) { favorite in
                                
                                HStack {
                                    Spacer()
                                    Rectangle()
                                        .frame(width: width * 0.8, height: height * 0.2)
                                        .cornerRadius(15)
                                        .foregroundStyle(Color(.secondary))
                                        .overlay(alignment: .topTrailing) {
                                            Button(action: {
                                                userFavorites.removeAll(where: { $0.title == favorite.title })
                                            }, label: {
                                                Image(systemName: "trash.circle")
                                                    .foregroundStyle(Color(.customComponent))
                                                    .font(.title)
                                                   // .padding(3)
                                            })
                                        }
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
                                                       // centerOnPlace(from: place)
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
                                    Spacer()
                                }
                      
                              
                            }
                        }
                    }
                }
                .padding()
            }
          
            
        
    }
}
#Preview {
    struct FavoritesPreviewHost: View {
        @State private var favorites: [LocationResult] = [
            LocationResult(title: "Test Title 1", subtitle: "Test Subtitle 1"),
            LocationResult(title: "Test Title 2", subtitle: "Test Subtitle 2"),
            LocationResult(title: "Test Title 3", subtitle: "Test Subtitle 3")
        ]
        
        var body: some View {
            FavoritesView(userFavorites: $favorites)
        }
    }
    
    return FavoritesPreviewHost()
}
