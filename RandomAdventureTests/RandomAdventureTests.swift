//
//  RandomAdventureTests.swift
//  RandomAdventureTests
//
//  Created by Nick Gordon on 7/14/25.
//

import Testing
@testable import RandomAdventure
struct RandomAdventureTests {

    @Test func testEmptySearchResults() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        //Given
       // let searchResults = [LocationResult]()
        let locationServices = LocationSearchServices()
    
        //When
       let emptyQuery = locationServices.query.isEmpty
        //Then
        #expect(emptyQuery == true)
        
    }
    
    
    @Test func testEmptySearchResultsWithEmptyQuery() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        //Given
        let locationServices = LocationSearchServices()
    
        //When
     //  let emptyQuery = locationServices.query.isEmpty
       let searchResults = locationServices.results
        //Then
        #expect(searchResults == [])
        
    }
    
    @Test func testEmptySearchResultsWithQueryThenBackToEmptyQuery() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        //Given
        let locationServices = LocationSearchServices()
    
        //When
        locationServices.query = "Detroit"
        //locationServices.query = ""
       let searchResults = locationServices.results
        //Then
        #expect(searchResults == [])
        
    }

}
