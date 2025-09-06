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
                ScrollView {
                    ForEach(userFavorites) { favorite in
                        
                        Rectangle()
                            .cornerRadius(15)
                            .foregroundStyle(Color(.secondary))
                            .frame(width: UIScreen.main.bounds.width * 0.93, height: UIScreen.main.bounds.width * 0.3)
                            .overlay(alignment: .center) {
                                VStack {
                                    Text(favorite.title)
                                    Text(favorite.subtitle)
                                }
                                .foregroundStyle(Color(.customComponent))
                            }
                            .overlay(alignment: .topTrailing) {
                                Button(action: {
                                    userFavorites.removeAll(where: { $0.title == favorite.title })
                                }, label: {
                                    Image(systemName: "heart.circle")
                                        .foregroundStyle(Color.pink)
                                        .font(.title)
                                        .padding(3)
                                })
                            }
                            
                        
                    }
                    .font(.largeTitle)
                    .bold()
                }
                .padding()
            }
        }
    }
}

//#Preview {
//    FavoritesView(userFavorites: [
//        
//        LocationResult(title: "Test Title", subtitle: "Test Subtitle"),
//        LocationResult(title: "Test Title", subtitle: "Test Subtitle"),
//        LocationResult(title: "Test Title", subtitle: "Test Subtitle"),
//        LocationResult(title: "Test Title", subtitle: "Test Subtitle"),
//        LocationResult(title: "Test Title", subtitle: "Test Subtitle")
//    ])
//}
