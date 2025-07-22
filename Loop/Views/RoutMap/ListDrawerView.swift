import SwiftUI

struct ListDrawerView: View {
    @State private var items: [ShoppingItem]
    @State private var toggledStates: [UUID: Bool] = [:]
    @State private var newItemName = ""
    @State private var newItemStore = ""
    
    init(items: [ShoppingItem]) {
        _items = State(initialValue: items)
    }
    
    // drawer measurement stuff //
    @State private var drawerOffset: CGFloat = 650
    @State private var dragStartOffset: CGFloat = 650
    private let collapsedOffset: CGFloat = 650  // where it rests when closed (adjust for desired peek)
    private let expandedOffset: CGFloat = 100   // where it rests when fully expanded
    // ----------------------- //
    
    var body: some View {
        let groupedItems = Dictionary(grouping: items, by: { $0.store })
        
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray)
                .frame(width: 40, height: 6)
                .padding(.vertical, 12)
            Text("Shopping List")
                .font(.headline)
            Divider()
                .padding(.top, 24)
            List {
                ForEach(groupedItems.keys.sorted(), id: \.self) { store in
                    Section(header: Text(store).font(.headline)) {
                        ForEach(groupedItems[store] ?? []) { item in
                            HStack {
                                Text(item.name).font(.body)
                                Spacer()
                                Button(action: {
                                    let current = toggledStates[item.id] ?? false
                                    toggledStates[item.id] = !current
                                }) {
                                    Image(systemName: (toggledStates[item.id] ?? false) ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.accentColor)
                                }
                                .buttonStyle(.plain)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    delete(item: item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 505)
            .listStyle(.insetGrouped)
            
            Divider()
            VStack(alignment: .leading) {
                Text("New Item").font(.title2)
                HStack {
                    TextField("Item Name", text: $newItemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Store Name", text: $newItemStore)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button {
                        addItem()
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title)
                    }
                    .disabled(newItemName.isEmpty || newItemStore.isEmpty)
                }
                .padding(.bottom, 75)
            }
            .padding(30)
        }
        .background(Color(.systemBackground))
        .cornerRadius(25)
        .shadow(radius: 10)
        .offset(y: drawerOffset)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = value.translation.height + dragStartOffset
                    if newOffset >= expandedOffset && newOffset <= collapsedOffset {
                        drawerOffset = newOffset
                    }
                }
                .onEnded { value in
                    dragStartOffset = drawerOffset
                    let midpoint = (collapsedOffset + expandedOffset) / 2
                    withAnimation {
                        if drawerOffset > midpoint {
                            drawerOffset = collapsedOffset
                        } else {
                            drawerOffset = expandedOffset
                        }
                    }
                    dragStartOffset = drawerOffset
                }
        )
    }
    
    private func delete(item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id}) {
            items.remove(at: index)
        }
    }
    
    private func addItem() {
        let newItem = ShoppingItem(name: newItemName, store: newItemStore)
        items.append(newItem)
        newItemName = ""
        newItemStore = ""
    }
}

#Preview {
    let sampleItems = [
        ShoppingItem(name: "Milk", store: "Whole Foods"),
        ShoppingItem(name: "Chocolate Milk", store: "Whole Foods"),
        ShoppingItem(name: "Car Battery", store: "AutoZone"),
        ShoppingItem(name: "Eggs", store: "Trader Joe's"),
        ShoppingItem(name: "Paper Towels", store: "Publix"),
    ]
    RouteMapView(items: sampleItems)
}
