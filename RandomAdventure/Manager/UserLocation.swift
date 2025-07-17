
import MapKit

@Observable class LocationSearchServices: NSObject {

    var query: String = "" {
        didSet {
            guard oldValue != query else { return }
            print("query empty: \(query.isEmpty)")
            handleSearchFragement(query)
        }
    }
    
    var results: [LocationResult] = []
   // var status: SearchStatus = .idle
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
         //   status = .idle
            return
        }
      //  status = .searching
        completer.queryFragment = query
    }
}


extension LocationSearchServices: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.map ({ result in
            LocationResult(title: result.title, subtitle: result.subtitle)
        })
     //   self.status = .results
    }





    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
   //     self.status = .error(error.localizedDescription)
    }
}

enum SearchStatus: Equatable {
    case idle
    case searching
    case error(String)
    case results
}

