//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-13.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared
    let transactionViewModel = TransactionListViewModel(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionViewModel)
        }
    }
}
