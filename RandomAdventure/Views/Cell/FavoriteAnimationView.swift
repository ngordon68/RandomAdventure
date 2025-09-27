//
//  FavoriteAnimationView.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 9/27/25.
//

import SwiftUI

struct FavoriteAnimationView: View {
 
    
    var body: some View {
        HStack(spacing: 10) {
                      Image(systemName: "heart.fill")
                          .font(.title3)
                          .foregroundStyle(.white)
                          .symbolEffect(.bounce, options: .repeat(1)) 

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
    
#Preview {
    FavoriteAnimationView()
}
