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
    
    @FocusState private var focusedField: CustomField?
    
    enum CustomField { case name, store }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(viewModel.items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.store)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { offsets in
                        viewModel.items.remove(atOffsets: offsets)
                    }
                }
                .listStyle(.insetGrouped)
                .background(Color(UIColor.systemGroupedBackground))
                
                Divider()
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("Item name", text: $viewModel.newItemName)
                            .focused($focusedField, equals: .name)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())

                        TextField("Store name", text: $viewModel.newStoreName)
                            .focused($focusedField, equals: .store)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())

                        Button(action: addItem) {
                          Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .padding(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.newItemName.isEmpty || viewModel.newStoreName.isEmpty)
                      }
                    
                    Button(action: { navigateToMap = true }) {
                        Text("Done")
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(viewModel.items.isEmpty
                                        ? Color.gray.opacity(0.4)
                                        : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.items.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Plan My Trip")
            .navigationDestination(isPresented: $navigateToMap) {
                RouteMapView(items: viewModel.items)
            }
        }
    }
    
    func addItem() {
        let newItem = ShoppingItem(
            name: viewModel.newItemName,
            store: viewModel.newStoreName
        )
        viewModel.items.append(newItem)
        viewModel.newItemName = ""
        viewModel.newStoreName = ""
    }
}
//#Preview {
//    let viewModel = ShoppingListViewModel()
//    viewModel.items = [
//        ShoppingItem(name: "Milk", store: "Whole Foods"),
//        ShoppingItem(name: "Chocolate Milk", store: "Whole Foods"),
//        ShoppingItem(name: "Car Battery", store: "AutoZone"),
//        ShoppingItem(name: "Eggs", store: "Trader Joe's"),
//        ShoppingItem(name: "Paper Towels", store: "Publix"),
//    ]
//    return ShoppingListEntryView(viewModel: viewModel)
//}
