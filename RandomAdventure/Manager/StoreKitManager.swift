//
//  StoreKitManager.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 10/16/25.
//

import Foundation
import StoreKit
import SwiftUI
import Observation

@Observable
class StoreKitManager {
    var tipProducts: [Product] = []
  
      func fetchTips() async {
          do {
              print("fetching products")
              tipProducts = try await Product.products(for: ["small.tip"])
          } catch {
              print("Failed to fetch tips: \(error)")
          }
      }
  
      func purchase(_ product: Product) async {
          do {
              let result = try await product.purchase()
              switch result {
              case .success(let verification):
                  print("Thanks for the tip!")
              default:
                  break
              }
          } catch {
              print("Purchase failed: \(error)")
          }
      }
}

