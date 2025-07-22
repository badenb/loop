import SwiftUI
import MapKit

struct RouteMapView: View {
    var items: [ShoppingItem]
    
    @StateObject private var locationManager = LocationManager()
    @State private var position = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    
    @State private var storeMapItems: [MKMapItem] = []
    @State private var routes: [MKRoute] = []
    @State private var autoCenter = true
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                UserAnnotation()
                
                ForEach(storeMapItems, id: \.self) { item in
                    Marker(item.name ?? "Store", coordinate: item.placemark.coordinate)
                }
                
                ForEach(routes.indices, id: \.self) { idx in
                    let route = routes[idx]
                    MapPolyline(route)
                        .stroke(.purple, lineWidth: 8)
                        .mapOverlayLevel(level: .aboveRoads)
                }
            }
            .ignoresSafeArea()
            .gesture(DragGesture().onChanged { _ in
                autoCenter = false
            })
            .gesture(MagnifyGesture().onChanged { _ in
                autoCenter = false
            })
            
            ListDrawerView(items: items)
        }
        .onReceive(locationManager.$userLocation.compactMap { $0 }) { userCord in
            guard autoCenter else { return }
            recenterMap(on: userCord)
            resolveStores(near: userCord)
        }
        .navigationBarHidden(true)
    }
    
    private func recenterMap(on coordinate: CLLocationCoordinate2D) {
        position = .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    private func resolveStores(near userCord: CLLocationCoordinate2D) {
        let storeNames = Set(items.map { $0.store })
        
        RoutePlanner.resolveStoreLocations(for: Array(storeNames), near: userCord) { mapItems in
            let orderedStores = RoutePlanner.tspOrder(stores: mapItems, from: userCord)
            storeMapItems = orderedStores
            
            routes.removeAll()
            
            var lastLocation = userCord
            for destination in orderedStores {
                let req = MKDirections.Request()
                req.source = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation))
                req.destination = destination
                req.transportType = .automobile
                
                MKDirections(request: req).calculate { response, _ in
                    guard let route = response?.routes.first else { return }
                    DispatchQueue.main.async {
                        routes.append(route)
                    }
                }
                
                lastLocation = destination.placemark.coordinate
            }
        }
    }
}

//#Preview {
//    let sampleItems = [
//        ShoppingItem(name: "Milk", store: "Whole Foods"),
//        ShoppingItem(name: "Chocolate Milk", store: "Whole Foods"),
//        ShoppingItem(name: "Car Battery", store: "AutoZone"),
//        ShoppingItem(name: "Eggs", store: "Trader Joe's"),
//        ShoppingItem(name: "Paper Towels", store: "Publix"),
//    ]
//    return NavigationView {
//        RouteMapView(items: sampleItems)
//    }
//}
