//
//  YelpModel.swift
//  RandomAdventure
//
//  Created by Nick Gordon on 3/26/23.
//

import Foundation

// MARK: - TestWorkSpace
struct AdventureArray: Codable {
    var businesses: [Adventure]?
    let total: Int?
    let region: Region?
}

// MARK: - Business
struct Adventure: Codable, Identifiable, Equatable {
    let id, alias, name: String
    let imageURL: String?
    let isClosed: Bool?
    let url: String?
    let reviewCount: Int?
    let categories: [Category]?
    let rating: Double?
    let coordinates: Center?
    let transactions: [String]?
    let location: Location?
    let phone, displayPhone: String?
    let distance: Double?
    let price: String?
    // new value here
    var isFavorite: Bool = true
    
    static func ==(lhs: Adventure, rhs: Adventure) -> Bool {
        return lhs.name == rhs.name && lhs.phone == rhs.phone
    }
    
    
    
    
    
static var example = Adventure(id: "mH5Bqv-5cVo-pjgKHBO8AQ",
                                   alias: "venture-x-detroit-financial-district-detroit",
                                   name: "Dummy data",
                                   imageURL: "https://s3-media4.fl.yelpcdn.com/bphoto/x8tkFoR0j_zPwfwprs1A7A/o.jpg",
                                   isClosed: false,
                                   url: "https://www.yelp.com/biz/venture-x-detroit-financial-district-detroit?adjust_creative=qfaTYwf9DF5TG57yVppGVA&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=qfaTYwf9DF5TG57yVppGVA",
                                   reviewCount: 2,
                                   categories: [],
                                   rating: 10,
                                   coordinates: nil,
                                   transactions: [],
                                   location: nil,
                                   phone: "281-330-8004",
                                   displayPhone: "10",
                                   distance: 10,
                                   price: "10")

    enum CodingKeys: String, CodingKey {
        case id, alias, name
        case imageURL = "image_url"
        case isClosed = "is_closed"
        case url
        case reviewCount = "review_count"
        case categories, rating, coordinates, transactions, location, phone
        case displayPhone = "display_phone"
        case distance, price
    }
}

// MARK: - Category
struct Category: Codable {
    let alias, title: String?
}

// MARK: - Center
struct Center: Codable {
    let latitude, longitude: Double?
}

// MARK: - Location
struct Location: Codable {
    let address1: String?
    let address2, address3: String?
    let city, zipCode, country, state: String?
    let displayAddress: [String]?

    enum CodingKeys: String, CodingKey {
        case address1, address2, address3, city
        case zipCode = "zip_code"
        case country, state
        case displayAddress = "display_address"
    }
}

// MARK: - Region
struct Region: Codable {
    let center: Center?
}

