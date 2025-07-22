//
//  LoopApp.swift
//  Loop
//
//  Created by Baden Bennett on 7/15/25.
//

import SwiftUI

@main
struct LoopApp: App {
    @StateObject private var viewModel = ShoppingListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ShoppingListEntryView(viewModel: viewModel)
        }
    }
}
