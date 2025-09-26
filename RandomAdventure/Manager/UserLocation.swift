
import MapKit

@Observable class LocationSearchServices: NSObject {
    
   var isShowingSearchbar: Bool = false

    var query: String = "" {
        didSet {
            guard oldValue != query else { return }
            print("query empty: \(query.isEmpty)")
            handleSearchFragement(query)
        }
    }
    
    var results: [LocationResult] = []
    var completer: MKLocalSearchCompleter
    
    init(filter: MKPointOfInterestFilter = .excludingAll,
         region: MKCoordinateRegion = MKCoordinateRegion(.world),
         types: MKLocalSearchCompleter.ResultType = [.pointOfInterest, .query, .address]) {
        
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.pointOfInterestFilter = filter
        completer.region = region
        completer.resultTypes = types
        
    }
    
    private func handleSearchFragement(_ query: String) {
        guard !query.isEmpty else {
            results.removeAll()
            return
        }
        completer.queryFragment = query
    }
}


extension LocationSearchServices: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.map ({ result in
            LocationResult(title: result.title, subtitle: result.subtitle)
        })
    }





    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    }
}

enum SearchStatus: Equatable {
    case idle
    case searching
    case error(String)
    case results
}

