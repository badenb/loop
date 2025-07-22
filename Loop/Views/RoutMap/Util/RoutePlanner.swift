import MapKit
import Foundation

class RoutePlanner {
    static func resolveStoreLocations(for stores: [String], near location: CLLocationCoordinate2D, completion: @escaping ([MKMapItem]) -> Void) {
        let group = DispatchGroup()
        var results: [MKMapItem] = []
        
        for store in stores {
            group.enter()
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = store
            request.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
            MKLocalSearch(request: request).start { response, error in
                defer { group.leave() }
                
                guard let response = response else { return }
                
                if let closest = response.mapItems.min(by: { lhs, rhs in
                    let lhsDistance = CLLocation(latitude: lhs.placemark.coordinate.latitude, longitude: lhs.placemark.coordinate.longitude)
                        .distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
                    
                    let rhsDistance = CLLocation(latitude: rhs.placemark.coordinate.latitude, longitude: rhs.placemark.coordinate.longitude)
                        .distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
                        
                    return lhsDistance < rhsDistance
                }) {
                    results.append(closest)
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    static func tspOrder(stores: [MKMapItem], from start: CLLocationCoordinate2D) -> [MKMapItem] {
        var remainingStores = stores
        var orderedStores: [MKMapItem] = []
        var currentLocation = start
        
        while !remainingStores.isEmpty {
            let (index, nearest) = remainingStores.enumerated().min { a, b in
                let aDistance = CLLocation(latitude: a.element.placemark.coordinate.latitude,
                                           longitude: a.element.placemark.coordinate.longitude)
                    .distance(from: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
                let bDistance = CLLocation(latitude: b.element.placemark.coordinate.latitude,
                                           longitude: b.element.placemark.coordinate.longitude)
                    .distance(from: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))

                return aDistance < bDistance
            }!
            
            orderedStores.append(nearest)
            remainingStores.remove(at: index)
            currentLocation = nearest.placemark.coordinate
        }
        
        return orderedStores
    }
}
