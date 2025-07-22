import SwiftUI

struct ShoppingItem: Identifiable {
    var id: UUID = UUID()
    var name: String
    var store: String
}

class ShoppingListViewModel: ObservableObject {
    @Published var items: [ShoppingItem] = []
    @Published var newItemName: String = ""
    @Published var newStoreName: String = ""
}

struct ShoppingListEntryView: View {
    @StateObject var viewModel: ShoppingListViewModel
    @State private var navigateToMap = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.items) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.store)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.items.remove(atOffsets: indexSet)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                     
                VStack {
                    HStack {
                        TextField("Item Name", text: $viewModel.newItemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Store Name", text: $viewModel.newStoreName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            guard !viewModel.newItemName.isEmpty, !viewModel.newStoreName.isEmpty else { return }
                            let newItem = ShoppingItem(name: viewModel.newItemName, store: viewModel.newStoreName)
                            viewModel.items.append(newItem)
                            viewModel.newItemName = ""
                            viewModel.newStoreName = ""
                        }) {
                            Image(systemName: "plus.circle.fill").font(.title)
                        }
                    }.padding()
                    
                    Button(action: {
                        navigateToMap = true
                    }) {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.items.isEmpty ? Color.gray.opacity(0.4) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    .navigationDestination(isPresented: $navigateToMap) {
                        RouteMapView(items: viewModel.items)
                    }
                }
            }
            .navigationTitle("Plan My Trip")
        }
    }
}

#Preview {
    let viewModel = ShoppingListViewModel()
    viewModel.items = [
        ShoppingItem(name: "Milk", store: "Whole Foods"),
        ShoppingItem(name: "Chocolate Milk", store: "Whole Foods"),
        ShoppingItem(name: "Car Battery", store: "AutoZone"),
        ShoppingItem(name: "Eggs", store: "Trader Joe's"),
        ShoppingItem(name: "Paper Towels", store: "Publix"),
    ]
    return ShoppingListEntryView(viewModel: viewModel)
}
